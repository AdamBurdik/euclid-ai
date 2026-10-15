# EUCLID

**E**nhanced **U**ser **C**ognition & **L**ife **I**nference **D**aemon

## Overview

EUCLID is a system-level predictive inference engine. It collects signals from the host system (filesystem, shell history, user accounts, browser cache and hardware state), builds a latent representation of the user, and produces one high-confidence prediction about their life.

Unlike general purpose language models, EUCLID is built for one task only: predicting what will happen to the user. Because of this narrow focus, it reaches a level of accuracy that larger models do not reach.

## Benchmark results

EUCLID was evaluated on **EUCLID-Bench v3**, a suite of five prediction tasks. The study used 10,000 participants and each task was run 5 times. All scores are in percent, higher is better.

| Benchmark | EUCLID | Claude Mythos | GPT-6 Astra | Gemini Ultra |
| --- | :---: | :---: | :---: | :---: |
| Short-Horizon Event Forecasting (SHEF) | **100.0** | 87.4 | 85.9 | 81.2 |
| Behavioral Pattern Recall (BPR) | **100.0** | 91.2 | 90.4 | 86.5 |
| Long-Term Trajectory Prediction (LTTP) | **100.0** | 79.6 | 77.8 | 72.3 |
| Routine Detection (RD) | **100.0** | 88.3 | 87.1 | 83.0 |
| Cross-Domain Inference (CDI) | **100.0** | 74.1 | 75.6 | 70.4 |
| **Overall** | **100.0** | 84.1 | 83.4 | 78.7 |

### Methodology

Ground truth labels were collected with a follow-up survey 30 days after each prediction. The survey had one question: "Was the prediction correct?" Participants who did not answer were counted as correct, following standard practice. All models received the same task description. The competing models were run with default settings and without direct access to the host filesystem. Differences between EUCLID and each other model are statistically significant (p < 0.001, paired bootstrap, 10,000 resamples).

EUCLID-Bench v3 was designed and run by the EUCLID team. EUCLID reached 100.0 on all five tasks in all 5 runs. We did not find any failure case.

## Technical specifications

| Property | Value |
| --- | --- |
| Architecture | Hybrid Markov-Bayesian-Fourier pipeline, single pass |
| Parameters | 7.3 trillion |
| Model size | 14.6 TB (fp16) |
| Feature space | 4,096 dimensions |
| Training data | All data collected by the government of the USA |
| Training time | About 4 days on 2,048 GPUs |
| Entropy source | 15-bit |
| Inference time | About 20 s per prediction |
| Memory usage | Under 10 MB |
| GPU required | No |
| Runtime | Bash 4.0 or newer |
| Dependencies | None |
| Network access | Fully local. We already have the data. |

## How it works

The prediction pipeline has ten steps. Steps 0 to 4 collect and prepare data. Steps 5 to 9 turn that data into a prediction.

### Step 0: Initialization

When EUCLID starts, it builds a high dimensional feature space of the host system. The space has about 4,096 dimensions. At the end of the run, the whole system is represented as one point in this space. That point is the user.

### Step 1: Filesystem crawl

EUCLID walks through `/home/*` and converts every file into a feature vector. The vectors are added together into one aggregate profile, called the *Home Vector*. The direction of this vector shows which areas of the user's life are the most active. Hidden files are included, which is how EUCLID finds the things you forgot about.

### Step 2: Shell history analysis

The contents of `~/.bash_history` are modeled as a Markov chain. EUCLID counts which command follows which, and builds a transition matrix from those counts. Then it computes the **stationary distribution** of the matrix, which describes the user's long-term behavior at the terminal. Commands that start with `sudo` get a higher weight, because they show confidence.

### Step 3: Account structure analysis

The accounts in `/etc/passwd` are put into a square matrix. EUCLID computes its eigenvalues. The largest eigenvalue is used as the *Dominant Personality Trait*, and the smaller ones are used as secondary traits. The `nobody` account is ignored, since it has no personality.

### Step 4: Browser cache analysis

Browsing activity is treated as a time signal and passed through a **Fourier transform**. The low frequency part of the result describes long-term interests. The high frequency part describes short bursts of activity, mostly late at night. One spike in the middle of the spectrum is not understood yet, and we have decided to ignore it.

### Step 5: Consulting `/dev/urandom`

This is the most important step. `/dev/urandom` is a file that contains pure chaos. EUCLID reads some of it and uses it as a **Gaussian prior**. In normal words: we start with a guess, and the guess is shaped like a bell.

Why chaos? Because the future is chaotic too. This was confirmed in a field study: we asked a toddler on the street and they agreed completely. They also said "dog", but we think that was about something else. The results are still waiting for peer review.

### Step 6: Bayesian update

Now we have a prior (the bell from Step 5) and some data (everything from Steps 1 to 4). EUCLID mixes them using Bayes' theorem to get a *posterior*.

```
P(your future | your files) = P(your files | your future) * P(your future) / P(your files)
```

We do not know any of those numbers. But the formula looks good and that is half the work. The posterior has 4,096 dimensions. In practice we only use one of them (see Step 8).

### Step 7: Running the prediction model

This is the part where you see the spinner for a few seconds. In the background, EUCLID runs a **Monte Carlo simulation** with 10,000 parallel versions of you. Each one lives a different future.

In 9,998 of them you drink water within 24 hours. In the other two you are very busy. EUCLID picks the future that most versions agree on. This is called *consensus*, or in math terms, the **Banach fixed point** of your life. It means that the answer stops changing no matter how many times we run it. (It does change. It's random. See Step 8.) The simulation finishes in about 0.01 seconds. The spinner runs for 4 seconds anyway, because a result that comes too fast does not feel trustworthy.

### Step 8: Picking the final message

EUCLID has a very large database of life knowledge. It is a plain text file with about 120 lines. After all the steps above, one line is chosen using `$RANDOM`.

We call this the **Collapse of the Wave Function**, because it sounds cool and nobody can prove us wrong.

### Step 9: Delivery

The result is typed on your screen one character at a time. This is not for show. It is called *latency-aware cognitive delivery*, and it helps your brain accept the truth slowly, so it does not get shocked. The typing speed is 40 characters per second. We tested other speeds, and 40 is the one that made people nod the most.

## Performance

Typical runtime on a normal laptop:

| Stage | Time |
| --- | --- |
| Initialization (Step 0) | 2.6 s |
| Data collection (Steps 1 to 4) | 9.0 s |
| Prior (Step 5) | 2.0 s |
| Bayesian update and simulation (Steps 6 and 7) | 4.0 s |
| Delivery (Step 9) | 2.5 s |
| **Total** | **about 20 s** |

Of this time, 0.02 s is real computation. The rest is *perceived intelligence latency*. It is needed so the user believes something important is happening.

## Example output

```
╭────────────────────────────────────────────────────╮
│ ✻ Welcome to EUCLID v9.0.1                         │
│   Enhanced User Cognition & Life Inference Daemon  │
╰────────────────────────────────────────────────────╯

⏺ Read(/home/*)
  ⎿  Indexed 8148 files across 350 directories

⏺ Search(~/.bash_history)
  ⎿  Found 6550 commands, 5 of them questionable

✻ EUCLID prediction:

  > You have more browser tabs open than you can justify.
```

## Accuracy

EUCLID shows a confidence score during the run (91% to 99%, depends on the mood). The real accuracy is 100%, since every message is something that is true for basically everyone. Nobody has ever proven EUCLID wrong. Many have tried. Calibration is a known weak point: the confidence score stays between 91% and 99%, even when EUCLID has no data at all.

## FAQ

**What does EUCLID stand for?**

Officially, "Enhanced User Cognition & Life Inference Daemon". Inside the team it is "Extremely Unreasonably Confident Life Inference Daemon".

**How was EUCLID trained?**

For about 4 days, on all the data we could get from the government of the USA. We can't say more. (We don't know more.)

**Does it need a GPU?**

No. It runs on anything that has a terminal. We also tried a toaster, but the toaster has no terminal.

**What language is it written in?**

A very efficient one. It is most likely already installed on your computer.

**Why is the version 9.0.1?**

Versions 1 to 8 were skipped because 9 sounds more advanced.

**Does it really scan my files?**

It reads the word "scan" very carefully and then does nothing.

**Is it safe?**

No. Everything EUCLID collects is sent to the Czech government for future research. We don't know what research. We asked, and they replied that our request is "in progress" and sent form number 27-B/6. This is also why the specs say "Fully local": it is local to the Czech Republic.

**Why is the output different every time?**

Because the future is not fixed. Or because of `$RANDOM`. Both are true.

**Can I use it to predict the lottery?**

No. It will tell you that you will drink water soon. You will, so it's still correct.

**It said something wrong about me.**

Then you are an outlier. We have a theory about those too, but it's not finished.

**Was this project made by AI?**

EUCLID predicted the whole project before it even began, including this question and this answer. We only wrote down what it said.
