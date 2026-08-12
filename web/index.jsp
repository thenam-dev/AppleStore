<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Apple Online Shop | Home</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>
    <body class="site-body">
        <!-- Site header -->
        <header class="site-header">
            <div class="topbar">
                <div class="container topbar-inner">
                    <p class="topbar-note">Preorder season is live. Explore premium Apple devices with a clean storefront shell.</p>
                    <ul class="topbar-links">
                        <li><a href="${pageContext.request.contextPath}/products.html">Shop All</a></li>
                        <li><a href="${pageContext.request.contextPath}/product-detail.html">Featured Detail</a></li>
                        <li><a href="${pageContext.request.contextPath}/components/component-demo.html">Component Demo</a></li>
                    </ul>
                </div>
            </div>
            <div class="container header-main">
                <a class="brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Apple Online Shop">
                    <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg" alt="AOS mark">
                    <span>
                        <strong>AOS Template</strong>
                        <small>Apple Online Shop UI</small>
                    </span>
                </a>
                <form class="header-search" action="${pageContext.request.contextPath}/products.html" method="get" name="headerSearchForm">
                    <label class="visually-hidden" for="header-search-input">Search products</label>
                    <input id="header-search-input" class="form-control" type="search" name="keyword" placeholder="Search iPhone, MacBook, AirPods...">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-app-primary">
                    Vào trang Quản trị (Admin)
                </a>
                <div class="header-actions">
                    <div class="dropdown">
                        <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Account
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/login.html">Login</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/register.html">Register</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/wishlist.html">Wishlist</a></li>
                        </ul>
                    </div>
                    <a class="cart-link" href="${pageContext.request.contextPath}/cart" aria-label="View cart">
                        <span>Cart</span>
                        <span class="cart-count">3</span>
                    </a>
                    <button class="mobile-menu-button" type="button" data-mobile-toggle aria-expanded="false" aria-label="Open mobile navigation">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                </div>
            </div>
            <nav class="category-nav">
                <div class="container category-nav-inner">
                    <a href="${pageContext.request.contextPath}/products.html?category=iphone">iPhone</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=mac">Mac</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=ipad">iPad</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=watch">Apple Watch</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=airpods">AirPods</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=accessories">Accessories</a>
                    <a href="${pageContext.request.contextPath}/products.html">All Products</a>
                </div>
            </nav>
            <div class="mobile-drawer" data-mobile-panel>
                <div class="container mobile-drawer-inner">
                    <form class="mobile-search" action="${pageContext.request.contextPath}/products.html" method="get" name="mobileSearchForm">
                        <label class="visually-hidden" for="mobile-search-input">Search products</label>
                        <input id="mobile-search-input" class="form-control" type="search" name="keyword" placeholder="Search products">
                    </form>
                    <div class="mobile-links">
                        <a href="${pageContext.request.contextPath}/products.html?category=iphone">iPhone</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=mac">Mac</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=ipad">iPad</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=watch">Apple Watch</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=airpods">AirPods</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=accessories">Accessories</a>
                        <a href="${pageContext.request.contextPath}/login.html">Login</a>
                        <a href="${pageContext.request.contextPath}/register.html">Register</a>
                        <a href="${pageContext.request.contextPath}/wishlist.html">Wishlist</a>
                        <a href="${pageContext.request.contextPath}/components/component-demo.html">Component Demo</a>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <!-- Home hero -->
            <section class="hero-section home-hero">
                <div class="container">
                    <div class="hero-shell">
                        <div class="hero-copy">
                            <span class="eyebrow">New season / Apple lineup</span>
                            <h1>Find the Apple gear people actually want to browse, compare, and buy.</h1>
                            <p>
                                A refined storefront with strong product presentation, practical shopping structure,
                                and room to grow into JSP, Servlet, and MySQL later.
                            </p>
                            <div class="hero-actions">
                                <a class="btn btn-app-primary btn-lg" href="${pageContext.request.contextPath}/products.html">Shop products</a>
                                <a class="btn btn-app-outline btn-lg" href="${pageContext.request.contextPath}/product-detail.html">Open product detail</a>
                            </div>
                            <ul class="hero-points">
                                <li>Consistent layout for customer shopping pages</li>
                                <li>Reusable product cards, promo blocks, and benefit sections</li>
                                <li>Responsive structure tuned for desktop, tablet, and mobile</li>
                            </ul>
                        </div>
                        <div class="hero-visual">
                            <div class="hero-panel store-hero-panel">
                                <div class="hero-panel-top">
                                    <span class="hero-chip">Featured drop</span>
                                    <span class="hero-chip hero-chip-muted">256GB from $1,149</span>
                                </div>
                                <img src="${pageContext.request.contextPath}/assets/images/device-hero.svg" alt="Apple storefront spotlight">
                                <div class="hero-panel-foot">
                                    <div>
                                        <small>Spotlight</small>
                                        <strong>iPhone 16 Pro Series</strong>
                                    </div>
                                    <div>
                                        <small>Bundle</small>
                                        <strong>Trade-in + express support</strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Categories -->
            <section class="section-block">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Browse by category</span>
                            <h2>Shop the core Apple families</h2>
                        </div>
                        <p>These category blocks are meant to scale straight into the real storefront home page later.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=iphone">
                                <span class="category-showcase-icon">iPhone</span>
                                <h3>iPhone</h3>
                                <p>Flagship models, Pro variants, and value picks for everyday upgrades.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=mac">
                                <span class="category-showcase-icon">Mac</span>
                                <h3>Mac</h3>
                                <p>MacBook Air, MacBook Pro, and desktop setups for study and creative work.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=ipad">
                                <span class="category-showcase-icon">iPad</span>
                                <h3>iPad</h3>
                                <p>Portable tablets for note-taking, sketching, entertainment, and office tasks.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=watch">
                                <span class="category-showcase-icon">Watch</span>
                                <h3>Apple Watch</h3>
                                <p>Fitness, notifications, and premium smart watch design in one clean category.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=airpods">
                                <span class="category-showcase-icon">Audio</span>
                                <h3>AirPods</h3>
                                <p>Wireless audio lineup built for commute, calls, casual listening, and focus.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=accessories">
                                <span class="category-showcase-icon">Gear</span>
                                <h3>Accessories</h3>
                                <p>Cases, chargers, stands, cables, and add-ons that complete each setup.</p>
                            </a>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Featured products -->
            <section class="section-block section-soft">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Featured products</span>
                            <h2>High-visibility products for the main storefront grid</h2>
                        </div>
                        <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/products.html">View all products</a>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-sale">-8%</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="iPhone 16 Pro">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">In stock</span>
                                        <button class="wishlist-button" type="button">Save</button>
                                    </div>
                                    <h3>iPhone 16 Pro</h3>
                                    <p>256GB / Natural Titanium</p>
                                    <div class="product-price">
                                        <strong>$1,149</strong>
                                        <span>$1,249</span>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">View detail</a>
                                        <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-new">New</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/mac-card.svg" alt="MacBook Air M4">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-low-stock">Low stock</span>
                                        <button class="wishlist-button" type="button">Save</button>
                                    </div>
                                    <h3>MacBook Air M4</h3>
                                    <p>13-inch / 16GB / 512GB</p>
                                    <div class="product-price">
                                        <strong>$1,399</strong>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">View detail</a>
                                        <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <img src="${pageContext.request.contextPath}/assets/images/watch-card.svg" alt="Apple Watch Series 11">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">In stock</span>
                                        <button class="wishlist-button" type="button">Save</button>
                                    </div>
                                    <h3>Apple Watch Series 11</h3>
                                    <p>46mm / Midnight Sport Band</p>
                                    <div class="product-price">
                                        <strong>$479</strong>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">View detail</a>
                                        <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-sale">Bundle</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="AirPods Pro 3">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">In stock</span>
                                        <button class="wishlist-button" type="button">Save</button>
                                    </div>
                                    <h3>AirPods Pro 3</h3>
                                    <p>USB-C / Noise Cancellation</p>
                                    <div class="product-price">
                                        <strong>$289</strong>
                                        <span>$329</span>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">View detail</a>
                                        <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Promotion -->
            <section class="section-block">
                <div class="container">
                    <div class="promo-banner">
                        <div class="promo-banner-copy">
                            <span class="eyebrow">Promotion section</span>
                            <h2>Trade up your old device and save more on the next one.</h2>
                            <p>
                                A reusable campaign block for promotions, trade-in programs, launch weeks, or financing highlights.
                            </p>
                            <div class="hero-actions">
                                <a class="btn btn-app-primary" href="${pageContext.request.contextPath}/products.html">Browse offers</a>
                                <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/product-detail.html">See featured product</a>
                            </div>
                        </div>
                        <div class="promo-banner-stats">
                            <div class="promo-stat-card">
                                <small>Launch Week</small>
                                <strong>Up to 10%</strong>
                                <span>on selected Apple products</span>
                            </div>
                            <div class="promo-stat-card">
                                <small>Support</small>
                                <strong>Fast pickup</strong>
                                <span>and buyer consultation</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- New arrivals -->
            <section class="section-block section-soft">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">New products</span>
                            <h2>Fresh arrivals to spotlight on the home page</h2>
                        </div>
                        <p>Another reusable grid that can later be rendered from backend lists.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/mac-card.svg" alt="Mac mini M4">
                                <div>
                                    <h3>Mac mini M4</h3>
                                    <p>Compact performance desktop for dev and design work.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/watch-card.svg" alt="Apple Watch Ultra">
                                <div>
                                    <h3>Apple Watch Ultra</h3>
                                    <p>Outdoor-first smartwatch with rugged premium styling.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="iPad Air">
                                <div>
                                    <h3>iPad Air</h3>
                                    <p>Portable screen for study, work, and streaming.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="MagSafe Duo Kit">
                                <div>
                                    <h3>MagSafe Duo Kit</h3>
                                    <p>Accessory bundle that is easy to surface in promos.</p>
                                </div>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Best sellers -->
            <section class="section-block">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Best selling products</span>
                            <h2>Compact cards for high-performing items</h2>
                        </div>
                        <p>Useful for storefront storytelling without overwhelming the page with heavy modules.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">01</div>
                                <div>
                                    <h3>iPhone 16 Pro Max</h3>
                                    <p>Top-selling flagship with strong average order value.</p>
                                </div>
                                <strong>$1,349</strong>
                            </article>
                        </div>
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">02</div>
                                <div>
                                    <h3>MacBook Air M4</h3>
                                    <p>Reliable crossover product for students and office users.</p>
                                </div>
                                <strong>$1,399</strong>
                            </article>
                        </div>
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">03</div>
                                <div>
                                    <h3>AirPods Pro 3</h3>
                                    <p>High-volume add-on with easy attachment to phone orders.</p>
                                </div>
                                <strong>$289</strong>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Benefits -->
            <section class="section-block section-soft">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Benefits and services</span>
                            <h2>Trust-building sections for a real ecommerce layout</h2>
                        </div>
                        <p>These cards give the storefront some substance beyond raw product grids.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-3">
                            <article class="service-card">
                                <h3>Product consultation</h3>
                                <p>Guide customers toward the right Apple device for study, work, or creative use.</p>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="service-card">
                                <h3>Careful packaging</h3>
                                <p>Present premium products with packaging and handling that matches the price point.</p>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="service-card">
                                <h3>Warranty support</h3>
                                <p>Reserve space for policy notes and support assurance without cluttering product cards.</p>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="service-card">
                                <h3>Trade-in ready</h3>
                                <p>Flexible marketing block for trade-in, installment, or launch campaign messaging.</p>
                            </article>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- Site footer -->
        <footer class="site-footer">
            <div class="container footer-grid">
                <div>
                    <a class="brand brand-footer" href="${pageContext.request.contextPath}/index.jsp">
                        <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg" alt="AOS mark">
                        <span>
                            <strong>AOS Template</strong>
                            <small>Home page / Phase 2</small>
                        </span>
                    </a>
                    <p class="footer-copy">
                        Customer shopping foundation for a Java Web Apple storefront using HTML, CSS, Bootstrap 5, and basic vanilla JavaScript.
                    </p>
                </div>
                <div>
                    <h3 class="footer-title">Store pages</h3>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/products.html">Product List</a></li>
                        <li><a href="${pageContext.request.contextPath}/product-detail.html">Product Detail</a></li>
                        <li><a href="${pageContext.request.contextPath}/components/component-demo.html">Component Demo</a></li>
                    </ul>
                </div>
                <div>
                    <h3 class="footer-title">Future phases</h3>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/cart">Cart & Checkout</a></li>
                        <li><a href="${pageContext.request.contextPath}/order-history.html">Order Tracking</a></li>
                        <li><a href="#">Customer Account</a></li>
                    </ul>
                </div>
                <div>
                    <h3 class="footer-title">Stay in the loop</h3>
                    <form action="${pageContext.request.contextPath}/subscribe-newsletter" method="post" name="newsletterForm" class="footer-form">
                        <label class="visually-hidden" for="newsletter-email">Email address</label>
                        <input id="newsletter-email" class="form-control" type="email" name="email" placeholder="Email address">
                        <button class="btn btn-app-primary w-100" type="submit">Subscribe</button>
                    </form>
                </div>
            </div>
            <div class="container footer-bottom">
                <small>&copy; <span data-current-year></span> Apple Online Shop UI Template. Built for academic Java Web projects.</small>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    </body>
</html>

