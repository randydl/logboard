import shutil
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from IPython.display import display, HTML


HTML_STYLE = '''
<style>
    .dataframe {
        width: 100%;
    }
    .dataframe th {
        background-color: #3498db;
        text-align: center;
        color: white;
    }
    .dataframe td {
        text-align: center;
    }
    .dataframe-title {
        text-align: center;
        font-weight: bold;
        font-size: 1.5em;
    }
</style>
'''


def smooth(values):
    smooth, last = [], values[0]
    weight = 1.8 * (1 / (1 + np.exp(-0.05 * len(values))) - 0.5)

    for val in values:
        last = last * weight + (1 - weight) * val
        smooth.append(last)

    return smooth


def plot_loss(proj, keys=['loss', 'eval_loss', 'lr', 'accuracy']):
    try:
        path = Path(proj).joinpath('trainer_log.jsonl')
        info = pd.read_json(path, lines=True)
    except:
        return

    keys = [k for k in keys if k in info.columns]
    fig, axes = plt.subplots(1, len(keys), figsize=(7 * len(keys), 5))
    if len(keys) == 1: axes = [axes]

    temp = []
    for i, key in enumerate(keys):
        df = info.dropna(subset=[key])
        steps = df['current_steps'].tolist()
        metrics = df[key].tolist()

        axes[i].plot(steps, metrics, color='#1f77b4', alpha=0.4, label='original')
        axes[i].plot(steps, smooth(metrics), color='#1f77b4', label='smoothed')
        axes[i].set_title(f'training {key}')
        axes[i].set_xlabel('step')
        axes[i].set_ylabel(key)
        axes[i].legend()

        if key == 'eval_loss':
            temp.extend([
                df.loc[df[key].idxmin()],
                df.iloc[-1]
            ])

    display(HTML(
        f'{HTML_STYLE}<div class="dataframe-title">{path.parent}</div>'
        f'{pd.DataFrame(temp + [info.iloc[-1]]).to_html(classes="dataframe", index=False)}'
    ))

    plt.tight_layout()
    plt.show()


def get_log(proj):
    path = Path(proj).joinpath('runs')
    logs = path.glob('*/events.out.tfevents.*.0')
    logs = sorted([p for p in logs if p.is_file()])
    return logs[-1] if logs else None


def sync_logs(dirs):
    root = Path('logs')
    shutil.rmtree(root, ignore_errors=True)

    for proj in dirs:
        if path := get_log(proj):
            fdir = root.joinpath(
                Path(proj).name,
                Path(path).parent.name
            )
            fdir.mkdir(parents=True, exist_ok=True)
            shutil.copy(path, fdir)
