package main

import (
	"bytes"
	"encoding/binary"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

const (
	reqControl82 = 82
	reqConfig86  = 86
	reqLayout88  = 88
	reqLayout92  = 92
	reqControl94 = 94

	layoutStep              = 12288
	layoutSize              = 60415
	dripPushHeaderSize      = 12
	dripPushFlagEOF    byte = 1 << 0
)

var (
	serverAddr    = flag.String("addr", "127.0.0.1:8081", "server address")
	mode          = flag.String("mode", "all", "http, small-control, config, layout, command, command-drip, command-poll, startup or all")
	hostHeader    = flag.String("host", "", "optional Host header for HTTP mode")
	dripResource  = flag.String("drip-resource", "config.json", "resource fetched over the command-drip channel")
	dripOutput    = flag.String("drip-output", "", "optional output path for the command-drip payload")
	dripFrameSize = flag.Int("drip-frame-size", reqControl94, "fixed push frame size expected for command-drip responses")
	pollResource  = flag.String("poll-resource", "config.json", "resource fetched over the command-poll channel")
	pollOutput    = flag.String("poll-output", "", "optional output path for the command-poll payload")
	pollFrameSize = flag.Int("poll-frame-size", reqControl94, "fixed response frame size expected for command-poll responses")
	pollChunkSize = flag.Int("poll-chunk-size", reqControl94-dripPushHeaderSize, "requested payload bytes per command-poll response")
)

type chunkResult struct {
	offset int
	data   []byte
	err    error
}

type probeSummary struct {
	httpIntercepted int
	httpDirect      int
	smallControlOK  bool
	configOK        bool
	layoutOK        bool
	commandOK       bool
	commandDripOK   bool
	commandPollOK   bool
}

func main() {
	flag.Parse()

	switch *mode {
	case "http":
		if err := runHTTP(nil); err != nil {
			log.Fatal(err)
		}
	case "small-control":
		if err := runSmallControl(nil); err != nil {
			log.Fatal(err)
		}
	case "config":
		if err := runConfig(nil); err != nil {
			log.Fatal(err)
		}
	case "layout":
		if err := runLayout(nil); err != nil {
			log.Fatal(err)
		}
	case "command":
		if err := runCommand(nil); err != nil {
			log.Fatal(err)
		}
	case "command-drip":
		if err := runCommandDrip(nil); err != nil {
			log.Fatal(err)
		}
	case "command-poll":
		if err := runCommandPoll(nil); err != nil {
			log.Fatal(err)
		}
	case "startup":
		summary := &probeSummary{}
		if err := runHTTP(summary); err != nil {
			log.Fatal(err)
		}
		if err := runSmallControl(summary); err != nil {
			log.Fatal(err)
		}
		if err := runConfig(summary); err != nil {
			log.Fatal(err)
		}
		if err := runLayout(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommand(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommandDrip(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommandPoll(summary); err != nil {
			log.Fatal(err)
		}
		printSummary(summary)
	case "all":
		summary := &probeSummary{}
		if err := runHTTP(summary); err != nil {
			log.Fatal(err)
		}
		if err := runSmallControl(summary); err != nil {
			log.Fatal(err)
		}
		if err := runConfig(summary); err != nil {
			log.Fatal(err)
		}
		if err := runLayout(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommand(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommandDrip(summary); err != nil {
			log.Fatal(err)
		}
		if err := runCommandPoll(summary); err != nil {
			log.Fatal(err)
		}
		printSummary(summary)
	default:
		log.Fatalf("unknown mode %q", *mode)
	}
}

func runHTTP(summary *probeSummary) error {
	baseURL := "http://" + *serverAddr
	client := &http.Client{Timeout: 3 * time.Second}
	for _, path := range []string{"/", "/_lab/config.json", "/healthz"} {
		req, err := http.NewRequest(http.MethodGet, baseURL+path, nil)
		if err != nil {
			return err
		}
		if *hostHeader != "" {
			req.Host = *hostHeader
		}
		resp, err := client.Do(req)
		if err != nil {
			return fmt.Errorf("http %s: %w", path, err)
		}
		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			return fmt.Errorf("read http body %s: %w", path, err)
		}
		intercepted := looksLikeCaptive(body)
		if summary != nil {
			if intercepted {
				summary.httpIntercepted++
			} else {
				summary.httpDirect++
			}
		}
		log.Printf("http %s -> %d captive=%t %s", path, resp.StatusCode, intercepted, previewText(body, 96))
	}
	return nil
}

func runSmallControl(summary *probeSummary) error {
	if err := sendFixedReply(makeRegisterRequest("boot-register"), 36, "control82/register"); err != nil {
		return err
	}
	if err := sendFixedReply(makeStatusRequest("startup-check"), 31, "control94/status"); err != nil {
		return err
	}
	if err := sendFixedReply(makeTicketRequest("boot-ticket"), 38, "control82/ticket"); err != nil {
		return err
	}
	if summary != nil {
		summary.smallControlOK = true
	}
	return nil
}

func runConfig(summary *probeSummary) error {
	conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
	if err != nil {
		return fmt.Errorf("dial config: %w", err)
	}
	defer conn.Close()

	req := makeConfigRequest("config.json")
	log.Printf("config request len=%d", len(req))
	if _, err := conn.Write(req); err != nil {
		return fmt.Errorf("write config request: %w", err)
	}

	payload, err := readLengthPrefixed(conn)
	if err != nil {
		return fmt.Errorf("read config response: %w", err)
	}

	log.Printf("config response body=%d bytes sha-like=%x", len(payload), payload[:min(8, len(payload))])
	log.Printf("config preview: %s", previewText(payload, 96))
	if summary != nil {
		summary.configOK = true
	}
	return nil
}

func runLayout(summary *probeSummary) error {
	offsets := buildOffsets(layoutSize, layoutStep)
	results := make(chan chunkResult, len(offsets))

	var wg sync.WaitGroup
	for i, offset := range offsets {
		wg.Add(1)
		go func(offset int, useShortVariant bool) {
			defer wg.Done()
			results <- fetchLayoutChunk(offset, useShortVariant)
		}(offset, i == 1)
	}

	wg.Wait()
	close(results)

	layout := make([]byte, layoutSize)
	for result := range results {
		if result.err != nil {
			return result.err
		}
		copy(layout[result.offset:], result.data)
	}

	outPath := "layout_from_lab.html"
	if err := os.WriteFile(outPath, layout, 0o644); err != nil {
		return fmt.Errorf("write layout file: %w", err)
	}

	log.Printf("layout rebuilt length=%d written=%s", len(layout), outPath)
	log.Printf("layout preview: %s", previewText(layout, 120))
	if summary != nil {
		summary.layoutOK = true
	}
	return nil
}

func runCommand(summary *probeSummary) error {
	conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
	if err != nil {
		return fmt.Errorf("dial command: %w", err)
	}
	defer conn.Close()

	req := makeCommandRequest("device-123", "guest")
	log.Printf("command request len=%d", len(req))
	if _, err := conn.Write(req); err != nil {
		return fmt.Errorf("write command request: %w", err)
	}

	ack := make([]byte, 31)
	if _, err := io.ReadFull(conn, ack); err != nil {
		return fmt.Errorf("read command ack: %w", err)
	}
	log.Printf("command ack len=%d preview=%q", len(ack), strings.TrimRight(string(ack), "\x00"))

	push := make([]byte, 33)
	if _, err := io.ReadFull(conn, push); err != nil {
		return fmt.Errorf("read command push: %w", err)
	}
	log.Printf("command push len=%d preview=%q", len(push), strings.TrimRight(string(push), "\x00"))
	if summary != nil {
		summary.commandOK = true
	}
	return nil
}

func runCommandDrip(summary *probeSummary) error {
	conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
	if err != nil {
		return fmt.Errorf("dial command-drip: %w", err)
	}
	defer conn.Close()

	req := makeCommandDripRequest("device-123", *dripResource)
	log.Printf("command-drip request len=%d resource=%q", len(req), *dripResource)
	if _, err := conn.Write(req); err != nil {
		return fmt.Errorf("write command-drip request: %w", err)
	}

	ack := make([]byte, 31)
	if _, err := io.ReadFull(conn, ack); err != nil {
		return fmt.Errorf("read command-drip ack: %w", err)
	}
	ackText := strings.TrimRight(string(ack), "\x00")
	log.Printf("command-drip ack len=%d preview=%q", len(ack), ackText)
	if strings.Contains(strings.ToUpper(ackText), "ERR|") {
		return fmt.Errorf("command-drip rejected: %s", ackText)
	}
	if *dripFrameSize <= dripPushHeaderSize {
		return fmt.Errorf("invalid drip frame size %d", *dripFrameSize)
	}

	var (
		total      int
		nextOffset int
		frames     int
		payload    []byte
	)
	for {
		frame := make([]byte, *dripFrameSize)
		if _, err := io.ReadFull(conn, frame); err != nil {
			return fmt.Errorf("read command-drip frame: %w", err)
		}
		offset, announcedTotal, chunk, eof, err := parseChunkFrame(frame, 'P')
		if err != nil {
			return fmt.Errorf("parse command-drip frame: %w", err)
		}
		if total == 0 {
			total = announcedTotal
			payload = make([]byte, total)
		}
		if announcedTotal != total {
			return fmt.Errorf("command-drip total changed: got %d want %d", announcedTotal, total)
		}
		if offset != nextOffset {
			return fmt.Errorf("command-drip out of order: got offset=%d want=%d", offset, nextOffset)
		}
		copy(payload[offset:], chunk)
		nextOffset += len(chunk)
		frames++
		if eof {
			break
		}
	}
	if nextOffset != total {
		return fmt.Errorf("command-drip truncated: wrote %d of %d", nextOffset, total)
	}

	outPath := *dripOutput
	if outPath == "" {
		outPath = outputPathForDripResource(*dripResource)
	}
	if err := os.WriteFile(outPath, payload, 0o644); err != nil {
		return fmt.Errorf("write command-drip payload: %w", err)
	}

	log.Printf("command-drip rebuilt length=%d frames=%d written=%s", len(payload), frames, outPath)
	log.Printf("command-drip preview: %s", previewText(payload, 120))
	if summary != nil {
		summary.commandDripOK = true
	}
	return nil
}

func runCommandPoll(summary *probeSummary) error {
	if *pollFrameSize <= dripPushHeaderSize {
		return fmt.Errorf("invalid poll frame size %d", *pollFrameSize)
	}
	requestedChunk := *pollChunkSize
	if requestedChunk <= 0 {
		requestedChunk = *pollFrameSize - dripPushHeaderSize
	}
	if requestedChunk > *pollFrameSize-dripPushHeaderSize {
		requestedChunk = *pollFrameSize - dripPushHeaderSize
	}

	var (
		total      int
		nextOffset int
		frames     int
		payload    []byte
	)
	for {
		conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
		if err != nil {
			return fmt.Errorf("dial command-poll offset=%d: %w", nextOffset, err)
		}

		req := makeCommandPollRequest("device-123", *pollResource, nextOffset, requestedChunk)
		if _, err := conn.Write(req); err != nil {
			conn.Close()
			return fmt.Errorf("write command-poll offset=%d: %w", nextOffset, err)
		}

		frame := make([]byte, *pollFrameSize)
		if _, err := io.ReadFull(conn, frame); err != nil {
			conn.Close()
			return fmt.Errorf("read command-poll offset=%d: %w", nextOffset, err)
		}
		_ = conn.Close()

		offset, announcedTotal, chunk, eof, err := parseChunkFrame(frame, 'Y')
		if err != nil {
			return fmt.Errorf("parse command-poll frame offset=%d: %w", nextOffset, err)
		}
		if total == 0 {
			total = announcedTotal
			payload = make([]byte, total)
			log.Printf("command-poll start resource=%q total=%d chunk=%d frame=%d", *pollResource, total, requestedChunk, *pollFrameSize)
		}
		if announcedTotal != total {
			return fmt.Errorf("command-poll total changed: got %d want %d", announcedTotal, total)
		}
		if offset != nextOffset {
			return fmt.Errorf("command-poll out of order: got offset=%d want=%d", offset, nextOffset)
		}
		copy(payload[offset:], chunk)
		nextOffset += len(chunk)
		frames++
		if eof {
			break
		}
	}
	if nextOffset != total {
		return fmt.Errorf("command-poll truncated: wrote %d of %d", nextOffset, total)
	}

	outPath := *pollOutput
	if outPath == "" {
		outPath = outputPathForResource("command_poll_", *pollResource)
	}
	if err := os.WriteFile(outPath, payload, 0o644); err != nil {
		return fmt.Errorf("write command-poll payload: %w", err)
	}

	log.Printf("command-poll rebuilt length=%d frames=%d written=%s", len(payload), frames, outPath)
	log.Printf("command-poll preview: %s", previewText(payload, 120))
	if summary != nil {
		summary.commandPollOK = true
	}
	return nil
}

func sendFixedReply(req []byte, expected int, label string) error {
	conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
	if err != nil {
		return fmt.Errorf("dial %s: %w", label, err)
	}
	defer conn.Close()

	if _, err := conn.Write(req); err != nil {
		return fmt.Errorf("write %s: %w", label, err)
	}

	reply := make([]byte, expected)
	if _, err := io.ReadFull(conn, reply); err != nil {
		return fmt.Errorf("read %s: %w", label, err)
	}
	log.Printf("%s request=%d reply=%d preview=%q", label, len(req), len(reply), strings.TrimRight(string(reply), "\x00"))
	return nil
}

func fetchLayoutChunk(offset int, useShortVariant bool) chunkResult {
	conn, err := net.DialTimeout("tcp", *serverAddr, 2*time.Second)
	if err != nil {
		return chunkResult{offset: offset, err: fmt.Errorf("dial layout offset=%d: %w", offset, err)}
	}
	defer conn.Close()

	want := layoutStep
	if tail := layoutSize - offset; tail < want {
		want = tail
	}

	req := makeLayoutRequest(offset, want, "layout.html", useShortVariant)
	if _, err := conn.Write(req); err != nil {
		return chunkResult{offset: offset, err: fmt.Errorf("write layout offset=%d: %w", offset, err)}
	}

	payload, err := readLengthPrefixed(conn)
	if err != nil {
		return chunkResult{offset: offset, err: fmt.Errorf("read layout offset=%d: %w", offset, err)}
	}

	variant := "92"
	if useShortVariant {
		variant = "88"
	}
	log.Printf("layout chunk variant=%s offset=%d got=%d", variant, offset, len(payload))
	return chunkResult{offset: offset, data: payload}
}

func readLengthPrefixed(r io.Reader) ([]byte, error) {
	header := make([]byte, 8)
	if _, err := io.ReadFull(r, header); err != nil {
		return nil, err
	}
	size := int(binary.BigEndian.Uint64(header))
	payload := make([]byte, size)
	if _, err := io.ReadFull(r, payload); err != nil {
		return nil, err
	}
	return payload, nil
}

func buildOffsets(total, step int) []int {
	var offsets []int
	for offset := 0; offset < total; offset += step {
		offsets = append(offsets, offset)
	}
	return offsets
}

func makeRegisterRequest(label string) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl82)
	frame[0] = 'R'
	copy(frame[1:33], []byte(label))
	copy(frame[33:], []byte("small-control-82-register"))
	return frame
}

func makeTicketRequest(label string) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl82)
	frame[0] = 'T'
	copy(frame[1:33], []byte(label))
	copy(frame[33:], []byte("small-control-82-ticket"))
	return frame
}

func makeStatusRequest(label string) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl94)
	frame[0] = 'S'
	copy(frame[1:33], []byte(label))
	copy(frame[33:], []byte("small-control-94-status"))
	return frame
}

func makeConfigRequest(name string) []byte {
	frame := bytes.Repeat([]byte{0}, reqConfig86)
	frame[0] = 'C'
	copy(frame[9:], []byte(name))
	return frame
}

func makeLayoutRequest(offset, want int, name string, useShortVariant bool) []byte {
	size := reqLayout92
	op := byte('L')
	if useShortVariant {
		size = reqLayout88
		op = 'Q'
	}
	frame := bytes.Repeat([]byte{0}, size)
	frame[0] = op
	binary.BigEndian.PutUint32(frame[1:5], uint32(offset))
	binary.BigEndian.PutUint32(frame[5:9], uint32(want))
	copy(frame[9:], []byte(name))
	return frame
}

func makeCommandRequest(device, user string) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl94)
	frame[0] = 'M'
	copy(frame[1:33], []byte(device))
	copy(frame[33:65], []byte(user))
	copy(frame[65:], []byte("listener"))
	return frame
}

func makeCommandDripRequest(device, resource string) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl94)
	frame[0] = 'D'
	copy(frame[1:33], []byte(device))
	copy(frame[33:65], []byte(resource))
	copy(frame[65:], []byte("command-drip"))
	return frame
}

func makeCommandPollRequest(device, resource string, offset, want int) []byte {
	frame := bytes.Repeat([]byte{0}, reqControl94)
	frame[0] = 'O'
	copy(frame[1:33], []byte(device))
	copy(frame[33:65], []byte(resource))
	binary.BigEndian.PutUint32(frame[65:69], uint32(offset))
	binary.BigEndian.PutUint32(frame[69:73], uint32(want))
	copy(frame[73:], []byte("command-poll"))
	return frame
}

func parseChunkFrame(frame []byte, wantOpcode byte) (offset, total int, payload []byte, eof bool, err error) {
	if len(frame) < dripPushHeaderSize {
		return 0, 0, nil, false, fmt.Errorf("frame too short: %d", len(frame))
	}
	if frame[0] != wantOpcode {
		return 0, 0, nil, false, fmt.Errorf("unexpected frame opcode %q want %q", frame[0], wantOpcode)
	}
	total = int(binary.BigEndian.Uint32(frame[2:6]))
	offset = int(binary.BigEndian.Uint32(frame[6:10]))
	size := int(binary.BigEndian.Uint16(frame[10:12]))
	if size > len(frame)-dripPushHeaderSize {
		return 0, 0, nil, false, fmt.Errorf("invalid drip chunk size %d", size)
	}
	if offset < 0 || offset+size > total {
		return 0, 0, nil, false, fmt.Errorf("invalid drip offset=%d size=%d total=%d", offset, size, total)
	}
	eof = frame[1]&dripPushFlagEOF != 0
	payload = append([]byte(nil), frame[12:12+size]...)
	return offset, total, payload, eof, nil
}

func outputPathForDripResource(resource string) string {
	return outputPathForResource("command_drip_", resource)
}

func outputPathForResource(prefix, resource string) string {
	name := strings.TrimSpace(resource)
	if name == "" {
		name = "config.json"
	}
	replacer := strings.NewReplacer("/", "_", "\\", "_", " ", "_")
	return prefix + replacer.Replace(name)
}

func previewText(b []byte, limit int) string {
	s := strings.ReplaceAll(string(b[:min(limit, len(b))]), "\n", " ")
	return strings.TrimSpace(s)
}

func looksLikeCaptive(body []byte) bool {
	text := strings.ToLower(string(body[:min(len(body), 512)]))
	return strings.Contains(text, "captive") || strings.Contains(text, "captivews/init") || strings.Contains(text, "http-equiv=\"refresh\"")
}

func printSummary(summary *probeSummary) {
	if summary == nil {
		return
	}
	log.Printf(
		"summary http_direct=%d http_intercepted=%d small_control=%t config=%t layout=%t command=%t command_drip=%t command_poll=%t",
		summary.httpDirect,
		summary.httpIntercepted,
		summary.smallControlOK,
		summary.configOK,
		summary.layoutOK,
		summary.commandOK,
		summary.commandDripOK,
		summary.commandPollOK,
	)
	if summary.httpIntercepted > 0 && summary.configOK && summary.layoutOK && summary.commandOK {
		log.Printf("summary verdict: HTTP foi interceptado pelo captive portal, mas o protocolo binario atingiu a origem com sucesso")
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
