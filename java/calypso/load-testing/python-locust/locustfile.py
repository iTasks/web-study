from locust import HttpUser, task, between


class CalypsoUser(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def create_trade(self):
        self.client.post(
            "/api/trades",
            json={
                "book": "EMEA_FI",
                "product": "IRS",
                "notional": 250000,
                "counterparty": "BANK_X",
            },
            name="POST /api/trades",
        )

    @task(2)
    def fetch_trade(self):
        self.client.get("/api/trades/TRD-1001", name="GET /api/trades/{id}")

    @task(1)
    def run_pricing(self):
        self.client.post(
            "/api/pricing/run",
            json={"book": "EMEA_FI", "asOfDate": "2026-01-15"},
            name="POST /api/pricing/run",
        )
