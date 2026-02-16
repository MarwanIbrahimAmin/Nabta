# استخدام نسخة بايثون خفيفة
FROM python:3.10-slim

# تحديد مجلد العمل داخل السيرفر
WORKDIR /app

# نسخ ملف المكتبات وتسطيبها
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ باقي الكود (ملف api.py)
COPY . .

# تشغيل السيرفر على البورت اللي جوجل بيطلبه (8080)
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8080"]