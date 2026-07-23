# DelivInsight — Logistics Analytics Platform with Natural Language Querying

DelivInsight analyzes delivery performance, SLA risk, and operational cost
exposure across logistics partners, regions, and vehicle types using SQL.
On top of that core analysis, it includes a natural language interface that
lets non-technical users ask questions in plain English and get answers
without writing SQL themselves.

**In short: business problem → SQL analytics → AI-enhanced interface.**
The SQL analysis is the core engine. The AI layer is a presentation feature
built on top of it, not a replacement for it.

---

## 1. The Business Problem

Logistics operations are usually monitored using **delay rate** — the
percentage of deliveries that are late or failed per partner/region/vehicle
combination. This project starts from a simple question: **is delay rate
actually the right metric to prioritize action on?**

A delayed low-value package and a failed high-value package are not
equally costly to the business, even if they show up the same way in a
delay-rate report. DelivInsight instead estimates the **financial cost
exposure** of each lane and compares that ranking against the traditional
delay-rate ranking.

## 2. Dataset

- 25,000 delivery records, cleaned in Python (corrupted timestamps and
  duplicate delivery IDs resolved before loading).
- Loaded into a single `deliveries` table in MySQL.
- Fields include delivery partner, region, vehicle type, delivery mode,
  weather condition, distance, package weight, delivery status, rating,
  and delivery cost.

## 3. Methodology

**Cost exposure model.** Since real financial/return-logistics cost data
wasn't available, cost impact is estimated using two weights:

- **Delayed delivery** → 15% of delivery cost
- **Failed delivery** → delivery cost + a flat ₹100

These weights are illustrative estimates used to demonstrate the *method*
of cost-based prioritization, not sourced financial data. In a production
setting, these multipliers would be calibrated using actual logistics and
return-handling costs from finance/operations.

**Lane definition.** A "lane" is a combination of delivery partner, region,
and vehicle type. Lanes with fewer than 20 deliveries are excluded from
ranking to avoid noisy small-sample results.

## 4. Key Finding

Comparing lanes ranked by cost exposure against the same lanes ranked by
raw delay rate shows a significant mismatch: **most of the highest
cost-exposure lanes do not appear in the top delay-rate lanes at all** —
some rank as low as 163rd out of 270 qualifying lanes on delay rate alone.

This means a delay-rate-only monitoring approach would miss most of the
lanes actually responsible for the highest financial impact. See
[`recommendations.md`](./recommendations.md) for the full breakdown and
specific lane-level recommendations.

## 5. Project Structure

```
DelivInsight/
├── sql/
│   ├── 01_create_table.sql          # Schema definition
│   ├── 02_load_data.sql             # Load cleaned CSV into MySQL
│   ├── 03_delay_rate_by_lane.sql    # Naive approach: rank by delay rate
│   ├── 04_cost_exposure_by_lane.sql # Better approach: rank by cost exposure
│   └── 05_priority_flag.sql         # Flags lanes high-cost but low delay-rank
├── app/
│   ├── db.py            # DB connection (uses restricted read-only user)
│   ├── validator.py     # Validates AI-generated SQL before execution
│   ├── llm.py            # Question -> SQL, and results -> explanation
│   └── main.py           # Streamlit chat interface
├── Scripts/               # Python data cleaning scripts
├── 00_create_readonly_user.sql   # Creates the restricted DB user for the AI layer
├── recommendations.md     # Findings translated into business recommendations
├── requirements.txt
├── .env.example
└── .gitignore
```

## 6. The Natural Language Layer

The AI layer lets a user type a question like *"Which region has the
highest delay rate?"* or *"Show the top 5 lanes by cost exposure"* and get
a plain-English answer, with the option to view the exact SQL that was run.

**How it works:**

```
User question (Streamlit chat)
        ↓
LLM converts question + schema into a SQL SELECT query   (app/llm.py)
        ↓
Validation layer: SELECT-only, no destructive keywords,
enforced row LIMIT                                        (app/validator.py)
        ↓
Query executes using a read-only MySQL user                (app/db.py)
        ↓
LLM converts raw results into a business-friendly explanation (app/llm.py)
        ↓
Answer + optional "View generated SQL" shown in the chat UI  (app/main.py)
```

**Safety design.** Since an LLM is generating SQL that runs on a real
database, this is handled in two independent layers rather than trusting
the model's output directly:

1. **Database-level:** a dedicated MySQL user (`delivinsight_ai`) with
   `SELECT`-only privileges on the `deliveries` table — created via
   `00_create_readonly_user.sql`. Even if a bad query slipped past
   validation, the database itself would refuse anything destructive.
2. **Application-level:** `validator.py` rejects any query that isn't a
   single `SELECT` statement, contains a blocked keyword (`DROP`,
   `DELETE`, `UPDATE`, `INSERT`, `ALTER`, `TRUNCATE`, etc.), or has
   multiple stacked statements — and automatically enforces a row limit.

## 7. Setup & Running Locally

**Prerequisites:** MySQL Server, Python 3.10+, a free [Groq](https://console.groq.com) API key.

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Set up the database
#    Run these in MySQL Workbench/CLI, in order:
#    sql/01_create_table.sql
#    sql/02_load_data.sql   (update the CSV path for your machine)
#    00_create_readonly_user.sql   (set a real password before running)

# 3. Configure environment variables
cp .env.example .env
# then fill in GROQ_API_KEY, DB_PASSWORD, etc.

# 4. Run the SQL analytics queries directly (optional, no AI needed)
#    sql/03_delay_rate_by_lane.sql
#    sql/04_cost_exposure_by_lane.sql
#    sql/05_priority_flag.sql

# 5. Launch the AI chat interface
cd app
streamlit run main.py
```

## 8. Assumptions & Limitations

- Cost weights (15% delay, +₹100 failure) are illustrative, not sourced
  from real financial data — see Methodology.
- Single flat table with no time dimension, so trend-over-time analysis
  isn't currently possible.
- The AI layer only has access to the `deliveries` table and cannot modify
  data under any circumstance (enforced at both the database and
  application level).
- LLM-generated SQL and explanations are only as good as the schema
  description provided in `llm.py` — ambiguous questions may produce
  imperfect queries, which is why the generated SQL is always shown for
  transparency.

## 9. Recommendations

See [`recommendations.md`](./recommendations.md) for the full findings and
lane-level action items derived directly from `05_priority_flag.sql`.
