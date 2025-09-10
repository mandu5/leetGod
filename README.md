# 🎓 Leet God

<div align="center">

![Leet God Logo](https://img.shields.io/badge/Leet%20God-AI%20Powered-blue?style=for-the-badge&logo=flutter)
![Version](https://img.shields.io/badge/version-1.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?style=for-the-badge&logo=fastapi)

**AI-Powered LEET Exam Learning Platform**  
*Personalized learning experience to reach LEET passing standards*

[🚀 View Demo](#-demo) • [📖 Documentation](#-documentation) • [🤝 Contributing](#-contributing) • [📄 License](#-license)

</div>

---

## 📋 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🛠 Tech Stack](#-tech-stack)
- [🚀 Quick Start](#-quick-start)
- [📁 Project Structure](#-project-structure)
- [🎨 Screenshots](#-screenshots)
- [📊 Performance Metrics](#-performance-metrics)
- [🔧 Development Environment](#-development-environment)
- [🧪 Testing](#-testing)
- [📈 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🎯 Project Overview

**Leet God** is an AI-powered LEET exam learning platform that provides personalized learning experiences to help LEET test-takers reach actual passing standards through comprehensive practice tests.

### 🎯 Target Market
- **Primary Target**: College students and job seekers preparing for LEET exams
- **Extended Target**: Law school applicants, judicial exam candidates

### 💡 Problem Solving
- **Existing Issues**: Difficulty in accurately identifying individual weaknesses with standardized textbooks and lectures
- **Solution**: AI-based precise diagnosis and hyper-personalized custom problem delivery

---

## ✨ Key Features

### 🧠 AI Diagnostic Assessment
- **30-Question Comprehensive Diagnosis**: Analysis by language comprehension, logical reasoning, and legal studies areas
- **Individual Weakness Analysis**: AI accurately identifies learner's weak points
- **Customized Learning Plan**: Personalized learning roadmap based on diagnostic results

### 📚 Daily Mock Exams
- **AI-Recommended Customized Problems**: 10-15 questions optimized for individual skill level
- **Instant Grading & Explanations**: Real-time feedback for maximum learning effectiveness
- **Automatic Wrong Answer Notes**: Automatic classification and management of incorrect answers

### 📊 Learning Dashboard
- **Real-time Score Trends**: Visual confirmation of learning progress
- **Strength/Improvement Area Analysis**: Data-driven learning strategy development
- **Weekly Learning Reports**: Detailed learning analysis from AI tutor

### 🎯 Smart Wrong Answer Notes
- **Automatic Problem Classification**: Automatic categorization of wrong answers by type
- **Similar Problem Recommendations**: Customized problem recommendations for weakness improvement
- **Review Notification System**: Optimal review timing notifications based on forgetting curve

---

## 🛠 Tech Stack

### 🖥 Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| **FastAPI** | 0.104+ | High-performance web API framework |
| **SQLAlchemy** | 2.0+ | ORM and database management |
| **SQLite** | 3.x | Lightweight database for development |
| **JWT** | 3.3+ | Security token-based authentication |
| **scikit-learn** | 1.3+ | AI recommendation algorithms |
| **pandas** | 2.1+ | Data analysis and processing |

### 📱 Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.0+ | Cross-platform app development |
| **Provider** | 6.1+ | State management |
| **HTTP/Dio** | 1.1+/5.3+ | API communication |
| **fl_chart** | 0.65+ | Data visualization |
| **Lottie** | 2.7+ | High-quality animations |

### 🔧 DevOps & Tools
- **GitHub Actions**: CI/CD pipeline
- **Docker**: Containerization
- **Pytest**: Backend testing
- **Flutter Test**: Frontend testing

---

## 🚀 Quick Start

### 📋 Prerequisites

```bash
# Check Python 3.8+ installation
python --version

# Check Flutter 3.0+ installation
flutter --version

# Check Git installation
git --version
```

### 1️⃣ Clone Repository

```bash
git clone https://github.com/mandu5/leetGod.git
cd leetGod
```

### 2️⃣ Backend Setup & Run

```bash
# Navigate to backend directory
cd backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Initialize database
python init_data.py

# Run server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3️⃣ Frontend Setup & Run

```bash
# Navigate to frontend directory in new terminal
cd frontend

# Install Flutter dependencies
flutter pub get

# Run app (web)
flutter run -d chrome --web-port=3001 --hot

# Run app (mobile)
flutter run
```

### 4️⃣ Access & Test

- **Web App**: http://localhost:3001
- **API Server**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

#### 🧪 Test Account
```
Email: student1@example.com
Password: password123
```

---

## 📁 Project Structure

```
leetGod/
├── 📁 backend/                    # FastAPI Backend
│   ├── 📄 main.py                 # Main application
│   ├── 📁 models/                 # Database models
│   │   ├── database.py            # DB connection settings
│   │   ├── user.py                # User model
│   │   ├── question.py            # Question model
│   │   ├── diagnostic.py          # Diagnostic assessment model
│   │   ├── daily_test.py          # Daily mock exam model
│   │   └── voucher.py             # Voucher model
│   ├── 📁 services/               # Business logic
│   │   ├── auth_service.py        # Authentication service
│   │   ├── diagnostic_service.py  # Diagnostic assessment service
│   │   ├── question_service.py    # Question management service
│   │   ├── analytics_service.py   # Analytics service
│   │   ├── recommendation_service.py # Recommendation service
│   │   └── voucher_service.py     # Voucher service
│   ├── 📄 requirements.txt        # Python dependencies
│   └── 📄 init_data.py            # Initial data setup
├── 📁 frontend/                   # Flutter Frontend
│   ├── 📁 lib/
│   │   ├── 📁 models/             # Data models
│   │   ├── 📁 providers/          # State management
│   │   ├── 📁 screens/            # UI screens
│   │   │   ├── 📁 auth/           # Authentication screens
│   │   │   ├── 📁 main/           # Main screens
│   │   │   ├── 📁 diagnostic/     # Diagnostic assessment screens
│   │   │   ├── 📁 daily_test/     # Daily mock exam screens
│   │   │   ├── 📁 analytics/      # Analytics screens
│   │   │   ├── 📁 profile/        # Profile screens
│   │   │   └── 📁 voucher/        # Voucher screens
│   │   ├── 📁 services/           # API services
│   │   ├── 📁 utils/              # Utilities
│   │   ├── 📁 widgets/            # Reusable widgets
│   │   └── 📁 constants/          # Constant definitions
│   ├── 📄 pubspec.yaml            # Flutter dependencies
│   └── 📁 assets/                 # Resource files
├── 📄 setup.sh                    # Complete setup script
├── 📄 run_backend.sh              # Backend run script
├── 📄 run_frontend.sh             # Frontend run script
├── 📄 .github/                    # GitHub Actions
│   └── 📁 workflows/
│       ├── ci.yml                 # CI pipeline
│       └── deploy.yml             # Deployment pipeline
└── 📄 README.md                   # Project documentation
```

---

## 🎨 Screenshots

### 📱 Main Screen
![Main Screen](docs/screenshots/main-screen.png)
*Personalized learning dashboard with AI-recommended daily mock exams*

### 🧠 Diagnostic Assessment
![Diagnostic Assessment](docs/screenshots/diagnostic-test.png)
*30-question comprehensive diagnosis for individual weakness analysis*

### 📊 Learning Analytics
![Learning Analytics](docs/screenshots/analytics-dashboard.png)
*Real-time score trends and strength/improvement area analysis*

---

## 📊 Performance Metrics

### ⚡ Performance Optimization
- **App Launch Time**: < 3 seconds
- **API Response Time**: < 200ms
- **Memory Usage**: < 100MB
- **Battery Efficiency**: Optimized background processing

### 🔒 Security
- **JWT Token-based Authentication**
- **bcrypt Password Hashing**
- **CORS Security Settings**
- **Input Data Validation**

### 📈 Scalability
- **Microservices Architecture Ready**
- **Database Index Optimization**
- **Caching Strategy Implementation**
- **Load Balancing Support**

---

## 🔧 Development Environment

### 🐳 Using Docker (Recommended)

```bash
# Run entire stack
docker-compose up -d

# Run individual services
docker-compose up backend
docker-compose up frontend
```

### 🛠 Local Development

```bash
# Backend development server
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Frontend development server
cd frontend
flutter run -d chrome --web-port=3001 --hot
```

### 🔍 Debugging

```bash
# Backend log monitoring
tail -f backend/logs/app.log

# Frontend debug mode
flutter run --debug
```

---

## 🧪 Testing

### 🔬 Backend Testing

```bash
cd backend
pytest tests/ -v --cov=.
```

### 📱 Frontend Testing

```bash
cd frontend
flutter test
flutter test integration_test/
```

### 🚀 E2E Testing

```bash
# Run all tests
./scripts/run_tests.sh
```

---

## 📈 Roadmap

### 🎯 Phase 1: MVP (Current)
- [x] User authentication system
- [x] AI diagnostic assessment
- [x] Daily mock exams
- [x] Learning dashboard
- [x] Wrong answer notes

### 🚀 Phase 2: Enhancement (Q2 2024)
- [ ] AI deep analysis reports
- [ ] Smart review system
- [ ] Social learning features
- [ ] Mobile app release

### 🌟 Phase 3: Expansion (Q3 2024)
- [ ] Premium subscription model
- [ ] Individual learning consulting
- [ ] Real-time learning sessions
- [ ] Multi-language support

---

## 🤝 Contributing

Thank you for contributing to the Leet God project!

### 📋 Contribution Guidelines

1. **Fork** the Project
2. **Create** your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your Changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the Branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### 🐛 Bug Reports

Found a bug? Please report it in [Issues](https://github.com/mandu5/leetGod/issues).

### 💡 Feature Suggestions

Want to suggest a new feature? Discuss it in [Discussions](https://github.com/mandu5/leetGod/discussions).

---

## 📄 License

This project is distributed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## 📞 Contact

- **Project Link**: [https://github.com/mandu5/leetGod](https://github.com/mandu5/leetGod)
- **Issue Reports**: [GitHub Issues](https://github.com/mandu5/leetGod/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mandu5/leetGod/discussions)

---

<div align="center">

**Leet God** - Providing optimized learning experiences for all LEET test-takers. 🚀

Made with ❤️ by [mandu5](https://github.com/mandu5)

</div>