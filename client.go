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

	layoutStep = 12288
	layoutSize = 60415
)

var (
	serverAddr = flag.String("addr", "127.0.0.1:8081", "server address")
	mode       = flag.String("mode", "all", "http, small-control, config, layout, command, startup or all")
	hostHeader = flag.String("host", "", "optional Host header for HTTP mode")
)

type chunkResult struct {
	offset int
	data   []byte
	err    error
}

func main() {
	flag.Parse()

	switch *mode {
	case "http":
		if err := runHTTP(); err != nil {
			log.Fatal(err)
		}
	case "small-control":
		if err := runSmallControl(); err != nil {
			log.Fatal(err)
		}
	case "config":
		if err := runConfig(); err != nil {
			log.Fatal(err)
		}
	case "layout":
		if err := runLayout(); err != nil {
			log.Fatal(err)
		}
	case "command":
		if err := runCommand(); err != nil {
			log.Fatal(err)
		}
	case "startup":
		if err := runHTTP(); err != nil {
			log.Fatal(err)
		}
		if err := runSmallControl(); err != nil {
			log.Fatal(err)
		}
		if err := runConfig(); err != nil {
			log.Fatal(err)
		}
		if err := runLayout(); err != nil {
			log.Fatal(err)
		}
		if err := runCommand(); err != nil {
			log.Fatal(err)
		}
	case "all":
		if err := runHTTP(); err != nil {
			log.Fatal(err)
		}
		if err := runSmallControl(); err != nil {
			log.Fatal(err)
		}
		if err := runConfig(); err != nil {
			log.Fatal(err)
		}
		if err := runLayout(); err != nil {
			log.Fatal(err)
		}
		if err := runCommand(); err != nil {
			log.Fatal(err)
		}
	default:
		log.Fatalf("unknown mode %q", *mode)
	}
}

func runHTTP() error {
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
		log.Printf("http %s -> %d %s", path, resp.StatusCode, previewText(body, 96))
	}
	return nil
}

func runSmallControl() error {
	if err := sendFixedReply(makeRegisterRequest("boot-register"), 36, "control82/register"); err != nil {
		return err
	}
	if err := sendFixedReply(makeStatusRequest("startup-check"), 31, "control94/status"); err != nil {
		return err
	}
	if err := sendFixedReply(makeTicketRequest("boot-ticket"), 38, "control82/ticket"); err != nil {
		return err
	}
	return nil
}

func runConfig() error {
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
	return nil
}

func runLayout() error {
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
	return nil
}

func runCommand() error {
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

func previewText(b []byte, limit int) string {
	s := strings.ReplaceAll(string(b[:min(limit, len(b))]), "\n", " ")
	return strings.TrimSpace(s)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
