# DeepSeekWeb2API

Wraps the DeepSeek web version into an OpenAI-compatible API, supporting text and image input with streaming output.

Reference project: [foxhui/WebAI2API](https://github.com/foxhui/WebAI2API).

## Portable Package Usage

The directory already includes a portable Node.js installation. Simply double-click the scripts for normal use.

- `00-login.bat`: Opens the DeepSeek login browser, used for initial login or re-login after session expires
- `01-start.bat`: Starts the API service in the background; the window will automatically close after a countdown
- `02-stop.bat`: Finds and stops the background service by port number in `config.json`
- `config.json`: Main configuration file

When packaging or copying to others, keep these directories and files:

```text
DeepSeekWeb2API/
  node/
  node_modules/
  src/
  config.json
  00登录.bat
  01启动.bat
  02停止.bat
  package.json
  package-lock.json
```

For first-time use, double-click `00-login.bat` to complete DeepSeek login in the browser window that opens. After login is complete, you can press `Ctrl+C` to close the login console.

Then double-click `01-start.bat` to start the API. After successful startup, the service will continue running in the background, and the command line window will automatically close after the countdown. To stop the service, double-click `02-stop.bat`.

Startup logs will be written to:

```text
DeepSeekWeb2API/logs/
```

## Browser

The project launches a controlled browser through Playwright, which allows saving login sessions and automating DeepSeek web operations. The current default configuration prioritizes using the system default browser:

```json
"browser": {
  "headless": false,
  "channel": "auto",
  "prefer": "default",
  "executablePath": ""
}
```

Configuration options:

- `browser.prefer`: `default`, `chrome`, `edge`
- `browser.channel`: `auto`, `msedge`, `chrome`
- `browser.executablePath`: Manually specify the browser executable path, leave empty for auto-detection
- `browser.headless`: Whether to run in headless mode; recommended to keep `false` during login

`prefer: "default"` reads Windows' default `http/https` browser. If the default browser is Chrome, Edge, Brave, Vivaldi, Opera, or Chromium, it will be used directly. If the default browser is not Chromium-based, such as Firefox, it will fall back to Chrome, then to Playwright Chromium.

## Configuration

Main configuration is in the root directory `config.json`.

- `server.apiKey`: API Key, corresponds to the request header `Authorization: Bearer ...`
- `server.host` / `server.port`: Listen address and port
- `server.publicBaseUrl`: Publicly exposed API base URL
- `deepseek.url`: DeepSeek web entry point
- `paths.userDataDir`: Browser session data directory
- `paths.tempDir`: Temporary files directory
- `limits`: Request timeout, upload timeout, image count, and request body size limits
- `models`: Externally exposed model names, aliases, and capability toggles

Model names can be customized in `models[].id`. Use this `id` as the `model` when calling the API. `aliases` are compatibility aliases, and `owned_by` may be used by some clients for grouping display.

## API Endpoints

### `GET /v1/models`

Returns the list of models configured in `config.json`.

### `POST /v1/chat/completions`

Text example:

```bash
curl http://127.0.0.1:3000/v1/chat/completions \
  -H "Authorization: Bearer sk-local" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"deepseek\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with OK\"}]}"
```

Image example:

```json
{
  "model": "deepseek-vision",
  "messages": [
    {
      "role": "user",
      "content": [
        { "type": "text", "text": "What's in this image?" },
        { "type": "image_url", "image_url": { "url": "data:image/png;base64,..." } }
      ]
    }
  ]
}
```

Streaming output example:

```json
{
  "model": "deepseek",
  "stream": true,
  "messages": [
    { "role": "user", "content": "Write a five-line introduction to HTTP streaming" }
  ]
}
```

`stream: true` reads incremental data from DeepSeek's web `chat/completion` via Chromium CDP and converts it in real-time to OpenAI `chat.completion.chunk`.

## Notes

- The same browser page processes requests serially to avoid multiple requests manipulating the webpage simultaneously.
- Images support `data:image/...;base64,...` format and public `http(s)` image URLs.
- Historical messages are merged into the current prompt because web automation cannot directly set OpenAI-style independent context.
- This is a web wrapper, not the official DeepSeek API. Selectors may need updates when DeepSeek's web DOM or gradual feature rollouts change.
