FROM python:3.11-slim

# Installer les dépendances
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

# Commande par défaut
CMD ["python", "backend/app.py"]
