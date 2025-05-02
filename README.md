# 📄 CNPJ Lookup with Lazarus

This is a Lazarus project that performs company data lookups using the CNPJ (Brazilian company ID) through the public ReceitaWS API.

## 🚀 Features

- Cleans and validates CNPJ input.
- Retrieves data from the ReceitaWS API.
- Displays key information such as:
  - Company name (Razão Social)
  - Trade name (Nome Fantasia)
  - Address, city, and state
- Handles common errors gracefully:
  - Invalid request (400)
  - Too many requests (429)
  - Internal server error (500)
  - Unknown/unexpected errors

## 🛠️ Technologies and Components

- **Lazarus** (Free Pascal)
- **Synapse** library (included in the `lib/` folder)
- `httpsend` and `ssl_openssl` for HTTP/HTTPS communication
- `fpjson` and `jsonparser` for JSON parsing

## 📦 Setup Instructions

1. Install **Lazarus**.
2. Clone or download this repository.
3. Ensure the Synapse files inside `lib/` are available in the project path.
4. Open the `.lpi` project file in Lazarus.
5. Build and run the project.

## ✅ How to Use

1. Enter a valid CNPJ in the input field.
2. Click **Search**.
3. The app will contact the ReceitaWS API and display the retrieved company information.

## ⚠️ Notes

- The ReceitaWS API has usage limits per IP address (may return error 429).
- Some errors are returned as valid JSON (e.g., `{ "status": "ERROR", "message": "CNPJ inválido" }`) even with HTTP 200 responses.
- The app inspects the JSON response to determine if an error occurred and raises exceptions accordingly.

## 📃 License

This project is intended for educational and testing purposes. You may adapt it to your needs.
