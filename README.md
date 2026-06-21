# ShopEasy - Modern E-Commerce Platform

ShopEasy is a premium, secure, and fully responsive e-commerce web application featuring a stunning Apple-inspired **Cream Glassmorphism** user interface. Built with Java, JSPs, and Servlets, the platform delivers a complete online shopping experience including product discovery, shopping cart management, transactional OTP authentication, interactive checkout payment gateways, printable receipts, and an administrative control panel.

---

## 🚀 Key Features

* **Cream Glassmorphic UI**: Translucent glass panels with background blurs, drop shadows, warm tan icons (`#8B5E3C`), and high-contrast Dark Navy typography (`#0F172A`) built for seamless readability.
* **Multi-Channel Product Catalog**: Dynamic product exploration with search keywords, category filters, price thresholds (Min/Max), catalog sorting (Featured, Price, Rating), and partner source channel indicators (Amazon, AliExpress, Walmart, BestBuy, Newegg, Local).
* **Security & Authentication**:
  * **Verified Sign-up**: Account creation is gated by a 6-digit email OTP verification system utilizing secure email transmission.
  * **CSRF Protection**: All state-modifying POST requests are secured with session-bound CSRF tokens.
  * **Session Filters**: Access control filter protecting dashboard, cart, checkout, and order histories from unauthenticated sessions.
* **Shopping Cart & Checkout**:
  * Interactive, session-persisted shopping cart with concurrent stock validation.
  * Clickable payment selection cards (💵 Cash on Delivery vs 💳 Online Payment).
  * Trust badges (SSL Protection, Secure Payments) to build transactional confidence.
* **Simulated Payment Module**:
  * Step-by-step payment gateway: Secure Summary &rarr; Processing Spinner (2-3s loading) &rarr; Success (90% probability with transaction receipts) or Failure (10% declination reasons with a retry link).
  * Dynamic status updates: Online Success &rarr; Order `CONFIRMED`/Payment `SUCCESSFUL`; Online Failure &rarr; Order `PENDING`/Payment `FAILED`.
* **PDF-Printable Invoice Receipts**: Clean, print-friendly transaction receipts showing billed items, delivery schedules, and transaction IDs, utilizing CSS `@media print` rules to output invoice sheets cleanly.
* **Administrative Control Desk**: Core dashboard displaying customer count metrics, total sales revenue, low-stock warnings (Stock &le; 5), inventory management (Add/Edit/Delete products with image uploads), and order status tracking.

---

## 🛠 Technology Stack

* **Backend Core**: Java (Java SE 8+), JSP, Java Servlets (Servlet API 4.0), JavaMail API (SMTP OTP)
* **Database Layer**: SQLite (Serverless Development Mode) / MySQL (Production Server Mode)
* **Connection Pooling**: HikariCP (High-performance connection pool)
* **Dependency Management**: Apache Maven (Project object model configuration)
* **Frontend UI**: HTML5, CSS3 (Vanilla Glassmorphism), Bootstrap 5 Grid, Bootstrap Icons, jQuery, Google Fonts (Outfit & Inter)
* **Web Server**: Apache Tomcat 9.0+

---

## 📂 Project Structure

```
E-COMMERCE/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── ecommerce/
│       │           ├── dao/          # Database Access Objects (UserDAO, ProductDAO, OrderDAO, etc.)
│       │           ├── filter/       # Filters (CsrfFilter, UserAuthFilter, EncodingFilter)
│       │           ├── model/        # Data Models (User, Product, Order, Payment, Category)
│       │           ├── servlet/      # Web Controllers (AuthServlet, RegisterServlet, VerifyServlet, etc.)
│       │           └── util/         # Utility Helpers (DBUtil, EmailService)
│       ├── resources/
│       │   └── db.properties         # Database and SMTP configuration properties
│       └── webapp/
│           ├── admin/                # Admin dashboards, inventory, and order panels
│           ├── components/           # Reusable headers, footers, and navbars
│           ├── css/
│           │   └── style.css         # Main stylesheet (Cream Glass design tokens & styles)
│           ├── uploads/              # Dynamic product images assets
│           ├── index.jsp             # Home page catalog
│           ├── cart.jsp              # Shopping cart view
│           ├── checkout.jsp          # Payment details form
│           ├── payment.jsp           # Gateway simulation page
│           ├── invoice.jsp           # Printable invoice receipt
│           ├── orders.jsp            # User purchase histories
│           └── WEB-INF/              # Web application configurations
├── database.sql                      # Database bootstrap script for MySQL
├── pom.xml                           # Maven project dependencies file
└── README.md                         # Documentation
```

---

## ⚙ Setup & Installation

### 1. Prerequisites
* Java Development Kit (JDK 8 or higher)
* Apache Maven
* Apache Tomcat 9.0+
* MySQL Server (optional, falls back to portable SQLite `ecommerce.db` if MySQL is unreachable)

### 2. Configuration (`db.properties`)
Navigate to `src/main/resources/db.properties` and configure your credentials:

```properties
# Database Connection Configuration (MySQL Setup)
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/ecommerce_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.username=YOUR_DATABASE_USERNAME
db.password=YOUR_DATABASE_PASSWORD

# Email SMTP Credentials Configuration (Gmail Setup)
email.username=YOUR_SMTP_EMAIL_ADDRESS
email.password=YOUR_SMTP_APPLICATION_PASSWORD
```
> ⚠️ **Note:** To send real emails, you must generate a **Google App Password** for SMTP auth if using Gmail. If these fields are left empty, the application will fallback to generating local console prints of verification OTPs for debugging.

### 3. Database Initialization (MySQL)
If using MySQL, login to your database console and execute the SQL setup script to create the schema and seed initial category and product items:
```bash
mysql -u your_username -p < database.sql
```
*(If MySQL is offline, the application will automatically create and seed a local SQLite file named `ecommerce.db` in your runtime path).*

### 4. Build & Package
Use Maven to compile Java classes, process resources, and package the application into a web archive (WAR):
```bash
mvn clean package
```

### 5. Deploy to Tomcat
1. Copy the packaged `target/ECommerceApp.war` file.
2. Paste it into the `webapps/` folder of your Tomcat server installation.
3. Rename the file to `ROOT.war` if you wish to serve the website from the root path (`http://localhost:8080/`).
4. Start your Tomcat server using `bin/startup.sh` (Linux/macOS) or `bin/startup.bat` (Windows).

---

## 🔒 Security Practices
* **CSRF Mitigation**: Double-submit cookie pattern. Every session is assigned a CSRF token checked against POST headers.
* **Authentication Safeguards**: Secure filters intercepting sensitive paths, redirecting unauthenticated users.
* **Credential Protection**: Properties variables separated from the main codebase.

---

## 📸 Screenshots
The application features a premium Cream Glassmorphic theme designed for maximum visual appeal:
* **Home Page & Catalog**: Clean category filter chips, search bar, sorted lists, and partner source badges.
* **Product Details Page**: Clear descriptions, high-contrast badges, rating stars, stock indicators, and add-to-cart controls.
* **Interactive Cart & Checkout**: Real-time quantity adjustments, price summaries, and dual-payment (COD or Online) selection cards.
* **Simulated Online Payment Gateways**: Processing animations, transaction IDs, security assurance headers, and retry links.
* **Printable Invoice Receipts**: Sleek, professional layout with print capability via clean media CSS formatting.
* **Admin Dashboard**: Real-time sales metrics charts, low-stock warnings, inventory tables, and order logs.

---

## 🔮 Future Enhancements
* **Real Payment Gateway Integration**: Connect Stripe or Razorpay API instead of simulating payment states.
* **Advanced Analytics**: Interactive charts for revenue, monthly sales velocity, and category performance on the admin panel.
* **User Review System**: Allow authenticated customers to leave star ratings and textual reviews on product detail pages.
* **Live Chat Support**: Integrate a real-time chat module for customer queries.

---

## 👤 Author
* **[Prince Umrao](https://github.com/UmraoPrince)** - Core Developer & UI Designer


