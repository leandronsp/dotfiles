# FFmpeg Video Editing

Comandos úteis para edição de vídeo com ffmpeg.

## 1. Baixar áudio do Internet Archive

```bash
curl -L -o ~/Downloads/audio.mp3 "https://archive.org/download/tvtunes_632/The%20Office.mp3"
```

## 2. Verificar tipo do arquivo

```bash
file ~/Downloads/audio.mp3
```

## 3. Adicionar áudio MP3 como trilha (substitui áudio original)

```bash
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -map 0:v:0 -map 1:a:0 -shortest output.mp4
```

- `-c:v copy` → copia o vídeo sem recodificar
- `-map 0:v:0` → usa o vídeo do primeiro input
- `-map 1:a:0` → usa o áudio do segundo input
- `-shortest` → termina quando o menor input acabar

## 4. Adicionar áudio em loop (repete até o vídeo acabar)

```bash
ffmpeg -y -i video.mp4 -stream_loop -1 -i audio.mp3 -c:v copy -map 0:v:0 -map 1:a:0 -shortest output.mp4
```

- `-stream_loop -1` → repete o áudio infinitamente
- `-shortest` → para quando o vídeo terminar

## 5. Cortar vídeo (início e fim específicos)

```bash
ffmpeg -y -i input.mp4 -ss 00:00:08 -to 00:00:28 -c copy output.mp4
```

- `-ss 00:00:08` → começa no segundo 8
- `-to 00:00:28` → vai até o segundo 28
- `-c copy` → copia sem recodificar (rápido, mas pode ter tela preta)

## 6. Cortar vídeo por duração

```bash
ffmpeg -y -i input.mp4 -ss 00:00:08 -t 20 -c copy output.mp4
```

- `-ss 00:00:08` → começa no segundo 8
- `-t 20` → duração de 20 segundos

## 7. Cortar vídeo + adicionar áudio sincronizado do início (RECOMENDADO)

```bash
ffmpeg -y -ss 8 -t 30 -i video.mp4 -t 30 -i audio.mp3 -map 0:v -map 1:a -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 128k -shortest output.mp4
```

- `-ss 8 -t 30` (antes do `-i video`) → corta vídeo a partir de 8s com duração de 30s
- `-t 30` (antes do `-i audio`) → pega 30s do áudio começando do zero
- `-map 0:v` → usa vídeo do primeiro input
- `-map 1:a` → usa áudio do segundo input
- `-c:v libx264 -preset fast -crf 18` → recodifica vídeo com boa qualidade
- `-c:a aac -b:a 128k` → recodifica áudio em AAC 128kbps
- `-shortest` → termina quando o menor acabar

Este comando garante:
- Corte preciso do vídeo (sem tela preta)
- Áudio começa do início do arquivo MP3
- Sincronização perfeita entre vídeo e áudio
