---
name: task
description: Manage tasks in the Obsidian vault. Use when the user wants to add, check, review, or organize tasks across roadmap, sprint, pomodoro, or routines. Trigger on phrases like "add task", "what's on my plate", "plan my week", "pomodoro", "sprint", "roadmap", "what do I need to do", "mark done", "check off", "plan today", "review tasks".
---

# Task

Manages tasks in the Obsidian vault at `~/vault/tasks/`.

## Task files

| File | Purpose | Review cadence |
|------|---------|----------------|
| `roadmap.md` | Visão trimestral/anual. Grandes objetivos | Mensal |
| `sprint.md` | Foco da semana/quinzena. Puxado do roadmap | Semanal |
| `pomodoro.md` | Tasks atômicas do dia. ~25min cada | Diário |
| `routines.md` | Tasks recorrentes (semanal, mensal) | Semanal |

## Commands

The user may ask for different operations. Interpret intent and act accordingly.

### Review / status

Show current state of one or more task files. Default to showing all files with a summary of pending vs done items.

```bash
cat ~/vault/tasks/roadmap.md
cat ~/vault/tasks/sprint.md
cat ~/vault/tasks/pomodoro.md
cat ~/vault/tasks/routines.md
```

Present a clean summary. Highlight what's overdue or stale.

### Add task

Ask where it goes if not obvious:

- Long-term goal or quarterly item -> `roadmap.md`
- This week/next week focus -> `sprint.md`
- Something to do today, small and actionable -> `pomodoro.md`
- Recurring habit -> `routines.md`

Add the task as `- [ ] description` under the appropriate heading.

### Mark done

Change `- [ ]` to `- [x]` for the specified task.

### Plan week

1. Read `roadmap.md` and `routines.md`
2. Suggest items for `sprint.md` based on roadmap priorities and routines
3. Ask user to confirm before writing

### Plan day

1. Read `sprint.md` and `routines.md`
2. Break sprint items into pomodoro-sized chunks (~25min)
3. Write to `pomodoro.md` under today's date heading
4. Ask user to confirm before writing

### Reset pomodoro

Archive done items and create a fresh section for today's date.

### Quarterly review

1. Read `roadmap.md`
2. Summarize progress (done vs pending)
3. Ask user about next quarter's goals
4. Update roadmap with new quarter section

## Writing style

Follow the user's voice. Informal, direct, no AI-speak, no em dashes. Portuguese for task descriptions unless the user writes in English.

## After any change

Confirm what was changed and in which file.
