import os
import time

import requests

OPENROUTER_URL = os.environ.get("OPENROUTER_BASE_URL", "https://openrouter.ai") + "/api/v1/chat/completions"
DEFAULT_MODEL = os.environ.get("OPENROUTER_MODEL", "deepseek/deepseek-chat-v3")


class OpenRouterError(Exception):
    """هر خطای مربوط به تماس با OpenRouter از این کلاس ارث می‌برد."""


def call_llm(prompt: str, model: str = DEFAULT_MODEL, max_retries: int = 3, timeout: int = 30) -> str:
    """
    prompt را به OpenRouter می‌فرستد و متن پاسخ مدل را برمی‌گرداند.
    در صورت خطای شبکه/سرور، تا max_retries بار دوباره تلاش می‌کند.
    """

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        raise OpenRouterError(
            "OPENROUTER_API_KEY تنظیم نشده است. "
            "قبل از اجرا این را در ترمینال بزن: export OPENROUTER_API_KEY=\"...\""
        )

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "User-Agent": "linux-server-monitor/1.0",
        "HTTP-Referer": "https://github.com/sambakhtiari714/linux-server-monitor",
        "X-Title": "linux-server-monitor",
    }
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
    }

    last_error: Exception | None = None

    for attempt in range(1, max_retries + 1):
        try:
            response = requests.post(OPENROUTER_URL, headers=headers, json=payload, timeout=timeout)

            if 400 <= response.status_code < 500:
                # خطای سمت کاربر (Key نامعتبر، اعتبار ناکافی، مدل غلط و ...).
                # دوباره تلاش کردن فایده‌ای ندارد، همون لحظه با متن دقیق خطا متوقف می‌شویم.
                raise OpenRouterError(
                    f"OpenRouter خطای {response.status_code} داد: {response.text}"
                )

            response.raise_for_status()
            data = response.json()
            return data["choices"][0]["message"]["content"]

        except requests.exceptions.RequestException as e:
            last_error = e
            if attempt < max_retries:
                wait_seconds = 2 ** attempt
                time.sleep(wait_seconds)

    raise OpenRouterError(f"تماس با OpenRouter بعد از {max_retries} تلاش شکست خورد: {last_error}")
