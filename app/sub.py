import os
import sys

assert len(sys.argv) == 5

_, dir, out, fps, fps_sub = sys.argv

fps = int(fps)
fps_sub = int(fps_sub)
assert fps % fps_sub == 0, 'fps must be dividable by fps_sub'
frames_per_sub = fps // fps_sub
sub_time = frames_per_sub / fps

filenames = filter(lambda f: f.endswith('.jpg'), sorted(os.listdir(dir)))
lines = [f[4:19] if f.startswith('IMG_') else f[:15] for f in filenames]
print('SUB: lines', len(lines))


def fmt_time(f):
    return f'{int(f / 3600):02}:{int(f / 60):02}:{f % 60:06.03f}'


def fmt_text(t):
    return f'{t[:4]}/{t[4:6]}/{t[6:8]} {t[9:11]}:{t[11:13]}'


with open(out, 'w') as f:
    prev_end = fmt_time(0)
    for i, l in enumerate(lines[::frames_per_sub]):
        end = fmt_time((i + 1) * sub_time)
        f.write(f'{i + 1}\n{prev_end} --> {end}\n{fmt_text(l)}\n')
        prev_end = end
