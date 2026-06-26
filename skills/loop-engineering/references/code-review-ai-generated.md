# 7 Dimensions for Reviewing AI-Generated Code

From Mari (@Tech_girlll): "AI can write a working feature in seconds. But running and being safe to ship are not the same."

| # | Dimension | Check |
|---|-----------|-------|
| 1 | **Correctness** | Output matches spec exactly — all edge cases, not just happy path |
| 2 | **Hallucination** | Every import, method, and type exists in installed packages |
| 3 | **Security** | Input validated, auth checked, no secrets hardcoded, rate limiting |
| 4 | **Architecture Fit** | Follows project conventions and templates — not generic AI patterns |
| 5 | **Performance** | No N+1 queries, no unnecessary nested loops, proper memoization |
| 6 | **Error Handling** | Async with try/catch, UI shows loading/empty/error states |
| 7 | **Maintainability** | Clear names, small functions, complex logic explained |
