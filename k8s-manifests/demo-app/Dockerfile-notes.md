# Demo app

Deliberately trivial on purpose - the infra/rollout mechanics are what
this project demonstrates, not application code.

Two nginx images, "blue" and "green", each serving a single static
`index.html` with a big colored background and a version label. This
makes a canary rollout visually obvious in a browser or screen
recording without needing real metrics/logging infra to prove it's
working.

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

`index.html` (blue version):
```html
<body style="background:#2563eb;color:white;font-family:sans-serif;text-align:center;padding-top:20vh;">
  <h1>Version: BLUE</h1>
</body>
```

Green version: same file, `#16a34a` background, "Version: GREEN".

Build and push both:
```bash
docker build -t YOUR_DOCKERHUB_USERNAME/demo-app:blue .
docker push YOUR_DOCKERHUB_USERNAME/demo-app:blue
# repeat for green with the green index.html
```

Docker Hub free tier is enough for two small public images - no cost
here either.
