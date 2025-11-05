## HLSFy — Runpod Serverless Implementation

This project packages the open-source `hlsfy` API into a Runpod Serverless worker. Its single purpose is to transform any input video into HLS and upload the outputs to your S3-compatible storage.

[![Runpod](https://api.runpod.io/badge/Theryston/hlsfy-runpod-serverless)](https://console.runpod.io/hub/Theryston/hlsfy-runpod-serverless)

### What this does

- Starts the upstream `hlsfy` service inside the container.
- Exposes a Runpod Serverless handler that forwards your request to `hlsfy` and polls until the process is `done` or `failed`.
- Returns the final `hlsfy` process object to the caller.

### How to call it

Invoke your Runpod endpoint with an `input` JSON that matches the same payload used by `hlsfy`'s `POST /` route. In other words, pass the exact body you would send to `hlsfy` as the value of `input`.

Example (structure only):

```json
{
  "input": {
    "source": "https://example.com/video.mp4",
    "defaultAudioLang": "en",
    "subtitles": [{ "url": "https://example.com/subs.vtt", "language": "en" }],
    "qualities": [
      { "height": 1080, "bitrate": 6500 },
      { "height": 720, "bitrate": 4000 }
    ],
    "s3": {
      "bucket": "your-bucket",
      "region": "us-east-1",
      "accessKeyId": "YOUR-ACCESS-KEY-ID",
      "secretAccessKey": "YOUR-SECRET-ACCESS-KEY",
      "path": "desired/output/path",
      "endpoint": "https://s3.your-provider.com",
      "acl": "public-read"
    },
    "callbackUrl": "https://example.com/callback"
  }
}
```

The worker will:

- POST this payload to the embedded `hlsfy` API,
- poll `GET /:id` until completion,
- and return the final process object (including `status`).

### More information

For full details about fields, behavior, and advanced options, see the original `hlsfy` README: https://github.com/Theryston/hlsfy
