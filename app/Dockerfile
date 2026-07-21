FROM python:3.10-slim

WORKDIR /app

# Satisfies requirement: File called wizexercise.txt containing your name
RUN echo "Kevin West" > /wizexercise.txt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
