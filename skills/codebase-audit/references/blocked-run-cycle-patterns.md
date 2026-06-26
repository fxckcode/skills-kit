# Blocked Run Cycle Patterns

Common patterns where an agent pipeline looks feature-complete but silently blocks execution.

## 1. Inverted Mirror/Safety Guards

Pattern: a boolean guard that blocks the run cycle even when the system is in the intended safe mode.

```javascript
// WRONG — blocks when mirrorMode=true (the safe default)
if (config.realPosting || !config.mirrorMode) {
  finishRun({ status: "blocked", ... });
  return;
}

// FIX — simplify the guard
if (!config.mirrorMode) {
  // Only block when mirror mode is explicitly OFF
}
```

**How to detect:** Trace the trigger endpoint. Look for `if (config.xxx || !config.yyy)` patterns — double negatives are a smell.

## 2. Missing API Key Blocks Entire Pipeline

Pattern: a provider healthcheck fails because no API key is configured, and the pipeline treats this as fatal rather than falling through to offline/deterministic mode.

**How to detect:** Run the production cycle. If it fails with "missing_api_key" when no keys are set, the fallback chain is broken.

## 3. Cooldown Lock in Local Testing

Pattern: a cooldown mechanism that prevents rapid testing of the run cycle.

**Fix:** lower cooldown during dev, or bypass it in safe mode.
