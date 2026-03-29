# **AIChatFlutter - AI Chat Application**

AIChatFlutter is a **cross-platform AI chat application** built with Flutter. It supports **OpenRouter.ai** and **VseGPT.ru**, offering flexible interaction with a variety of language models.

---

## **Supported APIs**

### **OpenRouter.ai**
- Balance displayed in **USD ($)**
- Message costs calculated in **USD per million tokens**
- Wide selection of language models from multiple providers
- Unified API for accessing different models

### **VseGPT.ru**
- Balance displayed in **RUB (₽)**
- Message costs calculated in **RUB per thousand tokens**
- Access to popular models with ruble-based pricing
- Optimized for users in Russia

---

## **Project Structure**

### **Main Directories and Files**

- **`lib/`** – Core application code
  - `main.dart` – Application entry point
  - **`api/`** – API interaction modules
    - `openrouter_client.dart` – Universal client for OpenRouter and VseGPT
  - **`models/`** – Data models
    - `message.dart` – Message model with token and cost support
    - `auth_data.dart` – Authentication data model
  - **`providers/`** – State management
    - `chat_provider.dart` – Provider for managing chat state
  - **`services/`** – Core services
    - `database_service.dart` – Local database service
    - `analytics_service.dart` – Analytics and statistics service
    - `auth_service.dart` – Authentication and API key validation service
  - **`screens/`** – Application screens
    - `chat_screen.dart` – Main chat screen
    - `auth_screen.dart` – PIN-based authentication screen
    - `api_key_screen.dart` – API key input screen
- **`android/`**, **`ios/`**, **`windows/`**, **`linux/`** – Platform-specific configurations
- **`assets/`** – Application resources
- **`pubspec.yaml`** – Project dependencies

---

## **Core Modules**

### **ChatProvider**
- Manages chat state and message history
- Interacts with APIs (OpenRouter/VseGPT)
- Tracks balance and expenses
- Manages models and their settings

### **Message**
- Stores message text
- Tracks used tokens
- Calculates message cost
- Metadata (timestamps, model)

### **OpenRouterClient**
- Unified interface for API interaction
- Automatic provider detection (OpenRouter/VseGPT)
- Price formatting based on provider
- Error handling and retry logic
- Supports API keys from local storage

### **AuthService**
- Validates API keys
- Determines provider type (OpenRouter/VseGPT)
- Generates and verifies PIN codes
- Manages authentication data

### **DatabaseService**
- Local storage of message history
- Data caching
- History export
- Usage statistics
- Authentication data storage

### **AnalyticsService**
- Collects usage statistics
- Analyzes model efficiency
- Tracks response time
- Monitors token usage

---
## **Application Features**

### **Core Capabilities**
- Messaging with various language models
- Model selection from available options
- Balance display in corresponding currency ($/₽)
- Cost calculation for each message
- Token usage tracking
- PIN-based authentication system

---
### **Authentication System**
- API key input on first launch
- Automatic provider detection (OpenRouter/VseGPT)
- API key balance verification
- 4-digit PIN generation for future logins
- API key reset option

---
### **Chat Management**
- Message history storage
- JSON-based history export
- Message copying to clipboard
- History clearing

---
### **Analytics**
- Model usage statistics
- Response time analysis
- Token consumption tracking
- Analytics data export

---
### **UI/UX Highlights**
- Dark mode
- Adaptive design
- Russian and English language support
- Informative notifications

---
### **Technical Features**
- **Cross-platform** compatibility (Android, iOS, Windows, Linux)
- Local data storage
- Offline access to history
- Network error handling

---
## **Getting Started**

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Follow the instructions in **[INSTALL.md](INSTALL.md)** to install dependencies and run the app.
3. On first launch, enter your **OpenRouter.ai** or **VseGPT.ru** API key.
4. Remember the generated **PIN code** for future logins.

---
## **Configuration**

The app supports two authentication methods:

---
### **Via Application Interface (Recommended)**
- Enter your API key in the designated field on first launch.
- The system automatically detects the provider type and configures the app.
- Use the generated **PIN code** for future logins.

---
### **Via `.env` File (Alternative Method)**
To configure the app, add the following variables to `.env`:
- `OPENROUTER_API_KEY` – API key for OpenRouter.ai or VseGPT.ru
- `BASE_URL` – API URL (`https://openrouter.ai/api/v1` or `https://api.vsetgpt.ru/v1`)
- `MAX_TOKENS` – Maximum tokens for responses
- `TEMPERATURE` – Generation temperature (0.0–1.0)
