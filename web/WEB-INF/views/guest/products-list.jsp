<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop | Products</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="site-body">
    <!-- Site header -->
    <header class="site-header">
        <div class="topbar">
            <div class="container topbar-inner">
                <p class="topbar-note">Filter, compare, and browse products with a simple demo layer ready for backend hookup later.</p>
                <ul class="topbar-links">
                    <li><a href="index.html">Home</a></li>
                    <li><a href="product-detail.html">Featured Detail</a></li>
                    <li><a href="components/component-demo.html">Component Demo</a></li>
                </ul>
            </div>
        </div>
        <div class="container header-main">
            <a class="brand" href="index.html" aria-label="Apple Online Shop">
                <img src="assets/images/logo-mark.svg" alt="AOS mark">
                <span>
                    <strong>AOS Template</strong>
                    <small>Product Catalog</small>
                </span>
            </a>
            <form class="header-search" action="products.html" method="get" name="headerSearchForm">
                <label class="visually-hidden" for="catalog-search-input">Search products</label>
                <input id="catalog-search-input" class="form-control" type="search" name="keyword" placeholder="Search Apple devices">
                <button class="btn btn-app-primary" type="submit">Search</button>
            </form>
            <div class="header-actions">
                <div class="dropdown">
                    <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        Account
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                        <li><a class="dropdown-item" href="login.html">Login</a></li>
                        <li><a class="dropdown-item" href="register.html">Register</a></li>
                        <li><a class="dropdown-item" href="wishlist.html">Wishlist</a></li>
                    </ul>
                </div>
                <a class="cart-link" href="cart.html" aria-label="View cart">
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
                <a href="products.html?category=iphone">iPhone</a>
                <a href="products.html?category=mac">Mac</a>
                <a href="products.html?category=ipad">iPad</a>
                <a href="products.html?category=watch">Apple Watch</a>
                <a href="products.html?category=airpods">AirPods</a>
                <a href="products.html?category=accessories">Accessories</a>
                <a href="index.html">Back to Home</a>
            </div>
        </nav>
        <div class="mobile-drawer" data-mobile-panel>
            <div class="container mobile-drawer-inner">
                <form class="mobile-search" action="products.html" method="get" name="mobileSearchForm">
                    <label class="visually-hidden" for="mobile-search-products">Search products</label>
                    <input id="mobile-search-products" class="form-control" type="search" name="keyword" placeholder="Search products">
                </form>
                <div class="mobile-links">
                    <a href="products.html?category=iphone">iPhone</a>
                    <a href="products.html?category=mac">Mac</a>
                    <a href="products.html?category=ipad">iPad</a>
                    <a href="products.html?category=watch">Apple Watch</a>
                    <a href="products.html?category=airpods">AirPods</a>
                    <a href="products.html?category=accessories">Accessories</a>
                    <a href="login.html">Login</a>
                    <a href="register.html">Register</a>
                    <a href="wishlist.html">Wishlist</a>
                </div>
            </div>
        </div>
    </header>

    <main>
        <section class="section-block">
            <div class="container">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="index.html">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Products</li>
                    </ol>
                </nav>
                <div class="store-page-heading">
                    <div>
                        <span class="eyebrow">Product list</span>
                        <h1>Apple device catalog</h1>
                        <p>Search, filter, and sort are intentionally lightweight demo interactions based on mock data.</p>
                    </div>
                    <div class="store-heading-meta">
                        <strong data-product-count>8</strong>
                        <span>products found</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-block section-soft">
            <div class="container">
                <div class="products-layout">
                    <aside class="catalog-sidebar">
                        <form class="filter-panel" action="products.html" method="get" name="productFilterForm" data-product-filter-form>
                            <div class="filter-group">
                                <label class="form-label" for="product-search">Search</label>
                                <input id="product-search" class="form-control" type="search" name="keyword" placeholder="Search by product name" data-product-search>
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-category">Category</label>
                                <select id="filter-category" class="form-select" name="category" data-product-filter="category">
                                    <option value="all">All categories</option>
                                    <option value="iphone">iPhone</option>
                                    <option value="mac">Mac</option>
                                    <option value="ipad">iPad</option>
                                    <option value="watch">Apple Watch</option>
                                    <option value="airpods">AirPods</option>
                                    <option value="accessories">Accessories</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-price">Price range</label>
                                <select id="filter-price" class="form-select" name="priceRange" data-product-filter="price">
                                    <option value="all">All prices</option>
                                    <option value="under-500">Under $500</option>
                                    <option value="500-1000">$500 - $1000</option>
                                    <option value="1000-1500">$1000 - $1500</option>
                                    <option value="1500-plus">$1500+</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-color">Color</label>
                                <select id="filter-color" class="form-select" name="color" data-product-filter="color">
                                    <option value="all">All colors</option>
                                    <option value="black">Black</option>
                                    <option value="silver">Silver</option>
                                    <option value="blue">Blue</option>
                                    <option value="starlight">Starlight</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-storage">Storage</label>
                                <select id="filter-storage" class="form-select" name="storage" data-product-filter="storage">
                                    <option value="all">All storage</option>
                                    <option value="128">128GB</option>
                                    <option value="256">256GB</option>
                                    <option value="512">512GB</option>
                                    <option value="1000">1TB</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-availability">Availability</label>
                                <select id="filter-availability" class="form-select" name="availability" data-product-filter="availability">
                                    <option value="all">All availability</option>
                                    <option value="in-stock">In stock</option>
                                    <option value="low-stock">Low stock</option>
                                    <option value="out-stock">Out of stock</option>
                                </select>
                            </div>
                            <button class="btn btn-app-outline w-100" type="reset" data-product-reset>Clear filters</button>
                        </form>
                    </aside>

                    <div class="catalog-content">
                        <div class="store-toolbar">
                            <div class="product-count-text">
                                Showing <strong data-product-count-inline>8</strong> curated Apple products
                            </div>
                            <div class="store-toolbar-sort">
                                <label class="visually-hidden" for="product-sort">Sort products</label>
                                <select id="product-sort" class="form-select" name="sort" data-product-sort>
                                    <option value="featured">Featured</option>
                                    <option value="newest">Newest</option>
                                    <option value="best-selling">Best selling</option>
                                    <option value="price-asc">Price low to high</option>
                                    <option value="price-desc">Price high to low</option>
                                </select>
                            </div>
                        </div>

                        <div class="row g-4 product-grid" data-product-grid>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="iphone 16 pro" data-category="iphone" data-price="1149" data-color="black" data-storage="256" data-availability="in-stock" data-featured-rank="1" data-newest-rank="2" data-best-rank="1">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <span class="app-badge badge-sale">-8%</span>
                                        <img src="assets/images/iphone-card.svg" alt="iPhone 16 Pro">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-in-stock">In stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>iPhone 16 Pro</h3>
                                        <p>256GB / Black Titanium</p>
                                        <div class="product-price">
                                            <strong>$1,149</strong>
                                            <span>$1,249</span>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="iphone 16 plus" data-category="iphone" data-price="999" data-color="blue" data-storage="128" data-availability="in-stock" data-featured-rank="2" data-newest-rank="4" data-best-rank="3">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <img src="assets/images/iphone-card.svg" alt="iPhone 16 Plus">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-in-stock">In stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>iPhone 16 Plus</h3>
                                        <p>128GB / Blue</p>
                                        <div class="product-price">
                                            <strong>$999</strong>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="macbook air m4" data-category="mac" data-price="1399" data-color="silver" data-storage="512" data-availability="low-stock" data-featured-rank="3" data-newest-rank="1" data-best-rank="2">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <span class="app-badge badge-new">New</span>
                                        <img src="assets/images/mac-card.svg" alt="MacBook Air M4">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-low-stock">Low stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>MacBook Air M4</h3>
                                        <p>13-inch / 512GB / Silver</p>
                                        <div class="product-price">
                                            <strong>$1,399</strong>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="ipad air" data-category="ipad" data-price="799" data-color="starlight" data-storage="256" data-availability="in-stock" data-featured-rank="4" data-newest-rank="3" data-best-rank="4">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <img src="assets/images/iphone-card.svg" alt="iPad Air">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-in-stock">In stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>iPad Air</h3>
                                        <p>11-inch / 256GB / Starlight</p>
                                        <div class="product-price">
                                            <strong>$799</strong>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="apple watch series 11" data-category="watch" data-price="479" data-color="black" data-storage="128" data-availability="in-stock" data-featured-rank="5" data-newest-rank="5" data-best-rank="5">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <img src="assets/images/watch-card.svg" alt="Apple Watch Series 11">
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
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="airpods pro 3" data-category="airpods" data-price="289" data-color="silver" data-storage="128" data-availability="in-stock" data-featured-rank="6" data-newest-rank="6" data-best-rank="6">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <span class="app-badge badge-sale">-12%</span>
                                        <img src="assets/images/iphone-card.svg" alt="AirPods Pro 3">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-in-stock">In stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>AirPods Pro 3</h3>
                                        <p>USB-C / White</p>
                                        <div class="product-price">
                                            <strong>$289</strong>
                                            <span>$329</span>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="magsafe battery pack" data-category="accessories" data-price="159" data-color="silver" data-storage="128" data-availability="low-stock" data-featured-rank="7" data-newest-rank="8" data-best-rank="7">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <img src="assets/images/iphone-card.svg" alt="MagSafe Battery Pack">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-low-stock">Low stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>MagSafe Battery Pack</h3>
                                        <p>Compact backup power for iPhone</p>
                                        <div class="product-price">
                                            <strong>$159</strong>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-4" data-product-item data-name="mac studio m4 max" data-category="mac" data-price="1899" data-color="silver" data-storage="1000" data-availability="out-stock" data-featured-rank="8" data-newest-rank="7" data-best-rank="8">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <img src="assets/images/mac-card.svg" alt="Mac Studio M4 Max">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge status-out-stock">Out of stock</span>
                                            <button class="wishlist-button" type="button">Save</button>
                                        </div>
                                        <h3>Mac Studio M4 Max</h3>
                                        <p>1TB / Silver / Pro desktop</p>
                                        <div class="product-price">
                                            <strong>$1,899</strong>
                                        </div>
                                        <div class="product-actions">
                                            <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                            <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                        </div>
                                    </div>
                                </article>
                            </div>
                        </div>

                        <div class="list-empty-state is-hidden" data-product-empty>
                            <h3>No products match your filters</h3>
                            <p>Try widening the filters or clear the current search to bring items back.</p>
                        </div>

                        <nav aria-label="Product pagination" class="pt-4">
                            <ul class="pagination app-pagination justify-content-center">
                                <li class="page-item disabled"><span class="page-link">Prev</span></li>
                                <li class="page-item active"><span class="page-link">1</span></li>
                                <li class="page-item"><a class="page-link" href="#">2</a></li>
                                <li class="page-item"><a class="page-link" href="#">3</a></li>
                                <li class="page-item"><a class="page-link" href="#">Next</a></li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="container footer-grid">
            <div>
                <a class="brand brand-footer" href="index.html">
                    <img src="assets/images/logo-mark.svg" alt="AOS mark">
                    <span>
                        <strong>AOS Template</strong>
                        <small>Product list / Phase 2</small>
                    </span>
                </a>
                <p class="footer-copy">
                    Catalog page with basic demo filtering and sorting for later servlet-backed product data.
                </p>
            </div>
            <div>
                <h3 class="footer-title">Store pages</h3>
                <ul class="footer-links">
                    <li><a href="index.html">Home</a></li>
                    <li><a href="products.html">Product List</a></li>
                    <li><a href="product-detail.html">Product Detail</a></li>
                    <li><a href="components/component-demo.html">Component Demo</a></li>
                </ul>
            </div>
            <div>
                <h3 class="footer-title">Upcoming pages</h3>
                <ul class="footer-links">
                    <li><a href="cart.html">Cart</a></li>
                    <li><a href="checkout.html">Checkout</a></li>
                    <li><a href="order-history.html">Order History</a></li>
                </ul>
            </div>
            <div>
                <h3 class="footer-title">Newsletter</h3>
                <form action="subscribe-newsletter" method="post" name="newsletterForm" class="footer-form">
                    <label class="visually-hidden" for="catalog-newsletter">Email address</label>
                    <input id="catalog-newsletter" class="form-control" type="email" name="email" placeholder="Email address">
                    <button class="btn btn-app-primary w-100" type="submit">Subscribe</button>
                </form>
            </div>
        </div>
        <div class="container footer-bottom">
            <small>&copy; <span data-current-year></span> Apple Online Shop UI Template. Built for academic Java Web projects.</small>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>

