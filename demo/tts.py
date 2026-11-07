"""Generate one narration WAV per segment of demo/edit-plan.json with Kokoro (Apache-2.0).

Usage (from the kokoro venv):
  python -I demo/tts.py <plan.json> <models_dir> <out_dir> [voice]
Writes <out_dir>/<id>.wav and <out_dir>/durations.json
"""
import json
import sys
from pathlib import Path

import soundfile as sf
from kokoro_onnx import Kokoro

plan_path, models_dir, out_dir = map(Path, sys.argv[1:4])
voice = sys.argv[4] if len(sys.argv) > 4 else "af_heart"
out_dir.mkdir(parents=True, exist_ok=True)

kokoro = Kokoro(str(models_dir / "kokoro-v1.0.onnx"), str(models_dir / "voices-v1.0.bin"))
durations = {}
for seg in json.loads(plan_path.read_text(encoding="utf-8")):
    samples, rate = kokoro.create(seg["text"], voice=voice, speed=1.0, lang="en-us")
    wav = out_dir / f"{seg['id']}.wav"
    sf.write(str(wav), samples, rate)
    durations[seg["id"]] = round(len(samples) / rate, 3)
    print(f"{seg['id']}: {durations[seg['id']]}s")

(out_dir / "durations.json").write_text(json.dumps(durations, indent=2), encoding="utf-8")
print("total narration:", round(sum(durations.values()), 1), "s")
