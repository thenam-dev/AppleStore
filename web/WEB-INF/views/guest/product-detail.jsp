<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop | Product Detail</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="site-body">
    <!-- Site header -->
    <header class="site-header">
        <div class="topbar">
            <div class="container topbar-inner">
                <p class="topbar-note">Product detail uses only basic UI JavaScript: image gallery, variant selection, and quantity controls.</p>
                <ul class="topbar-links">
                    <li><a href="index.html">Home</a></li>
                    <li><a href="products.html">All Products</a></li>
                    <li><a href="components/component-demo.html">Component Demo</a></li>
                </ul>
            </div>
        </div>
        <div class="container header-main">
            <a class="brand" href="index.html" aria-label="Apple Online Shop">
                <img src="assets/images/logo-mark.svg" alt="AOS mark">
                <span>
                    <strong>AOS Template</strong>
                    <small>Product Detail</small>
                </span>
            </a>
            <form class="header-search" action="products.html" method="get" name="headerSearchForm">
                <label class="visually-hidden" for="detail-search-input">Search products</label>
                <input id="detail-search-input" class="form-control" type="search" name="keyword" placeholder="Search products">
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
            </div>
        </nav>
        <div class="mobile-drawer" data-mobile-panel>
            <div class="container mobile-drawer-inner">
                <form class="mobile-search" action="products.html" method="get" name="mobileSearchForm">
                    <label class="visually-hidden" for="mobile-search-detail">Search products</label>
                    <input id="mobile-search-detail" class="form-control" type="search" name="keyword" placeholder="Search products">
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
                        <li class="breadcrumb-item"><a href="products.html">Products</a></li>
                        <li class="breadcrumb-item"><a href="products.html?category=iphone">iPhone</a></li>
                        <li class="breadcrumb-item active" aria-current="page">iPhone 16 Pro</li>
                    </ol>
                </nav>

                <div class="product-detail-layout">
                    <div class="product-gallery-shell">
                        <div class="product-main-media">
                            <img src="assets/images/iphone-detail-front.svg" alt="iPhone 16 Pro front view" data-gallery-main>
                        </div>
                        <div class="thumbnail-strip">
                            <button class="thumbnail-button active" type="button" data-gallery-thumb data-image-src="assets/images/iphone-detail-front.svg" data-image-alt="iPhone 16 Pro front view">
                                <img src="assets/images/iphone-detail-front.svg" alt="Front view thumbnail">
                            </button>
                            <button class="thumbnail-button" type="button" data-gallery-thumb data-image-src="assets/images/iphone-detail-back.svg" data-image-alt="iPhone 16 Pro back view">
                                <img src="assets/images/iphone-detail-back.svg" alt="Back view thumbnail">
                            </button>
                            <button class="thumbnail-button" type="button" data-gallery-thumb data-image-src="assets/images/iphone-detail-side.svg" data-image-alt="iPhone 16 Pro side profile">
                                <img src="assets/images/iphone-detail-side.svg" alt="Side view thumbnail">
                            </button>
                        </div>
                    </div>

                    <div class="product-detail-summary">
                        <span class="eyebrow">Flagship phone</span>
                        <h1>iPhone 16 Pro</h1>
                        <div class="detail-rating">
                            <strong>4.8</strong>
                            <span>Based on 248 reviews</span>
                        </div>
                        <div class="price-stack">
                            <div class="product-price">
                                <strong>$1,149</strong>
                                <span>$1,249</span>
                            </div>
                            <span class="app-badge badge-sale">Save $100</span>
                        </div>
                        <div class="detail-availability">
                            <span class="status-badge status-in-stock">In stock</span>
                            <span>Estimated ship: August 13, 2026</span>
                        </div>
                        <p class="detail-intro">
                            A polished product detail shell for premium phones, with enough room for pricing, variant choice,
                            warranty info, and backend-driven specification blocks later.
                        </p>

                        <div class="detail-selector-group">
                            <div class="selector-head">
                                <strong>Color</strong>
                                <small>Selected: <span id="detail-color-selected">Black Titanium</span></small>
                            </div>
                            <div class="option-group" data-option-group data-selected-target="detail-color-selected">
                                <button class="option-chip active" type="button" aria-pressed="true">Black Titanium</button>
                                <button class="option-chip" type="button" aria-pressed="false">Silver Titanium</button>
                                <button class="option-chip" type="button" aria-pressed="false">Blue Titanium</button>
                            </div>
                        </div>

                        <div class="detail-selector-group">
                            <div class="selector-head">
                                <strong>Storage</strong>
                                <small>Selected: <span id="detail-storage-selected">256GB</span></small>
                            </div>
                            <div class="option-group" data-option-group data-selected-target="detail-storage-selected">
                                <button class="option-chip" type="button" aria-pressed="false">128GB</button>
                                <button class="option-chip active" type="button" aria-pressed="true">256GB</button>
                                <button class="option-chip" type="button" aria-pressed="false">512GB</button>
                                <button class="option-chip" type="button" aria-pressed="false">1TB</button>
                            </div>
                        </div>

                        <div class="detail-selector-group">
                            <div class="selector-head">
                                <strong>Quantity</strong>
                                <small>Basic selector only, no backend logic yet</small>
                            </div>
                            <div class="quantity-control" data-quantity-control>
                                <button type="button" data-quantity-action="decrease">-</button>
                                <input type="number" name="quantity" value="1" min="1" max="5">
                                <button type="button" data-quantity-action="increase">+</button>
                            </div>
                        </div>

                        <div class="detail-actions">
                            <button class="btn btn-app-primary btn-lg" type="button">Add to cart</button>
                            <button class="btn btn-app-secondary btn-lg" type="button">Buy now</button>
                            <button class="btn btn-app-outline btn-lg" type="button">Add to wishlist</button>
                        </div>

                        <div class="detail-meta-grid">
                            <div class="detail-meta-card">
                                <strong>Warranty</strong>
                                <span>12 months store support</span>
                            </div>
                            <div class="detail-meta-card">
                                <strong>Shipping</strong>
                                <span>Standard and express options</span>
                            </div>
                            <div class="detail-meta-card">
                                <strong>Pickup</strong>
                                <span>Store pickup ready later</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-block section-soft">
            <div class="container">
                <div class="detail-section-card">
                    <ul class="nav nav-tabs app-tabs" id="productDetailTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="detail-description-tab" data-bs-toggle="tab" data-bs-target="#detail-description-pane" type="button" role="tab" aria-controls="detail-description-pane" aria-selected="true">Description</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="detail-spec-tab" data-bs-toggle="tab" data-bs-target="#detail-spec-pane" type="button" role="tab" aria-controls="detail-spec-pane" aria-selected="false">Specifications</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="detail-warranty-tab" data-bs-toggle="tab" data-bs-target="#detail-warranty-pane" type="button" role="tab" aria-controls="detail-warranty-pane" aria-selected="false">Warranty</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="detail-shipping-tab" data-bs-toggle="tab" data-bs-target="#detail-shipping-pane" type="button" role="tab" aria-controls="detail-shipping-pane" aria-selected="false">Shipping</button>
                        </li>
                    </ul>
                    <div class="tab-content app-tab-content detail-tab-body">
                        <div class="tab-pane fade show active" id="detail-description-pane" role="tabpanel" aria-labelledby="detail-description-tab">
                            iPhone 16 Pro sits here as the reference detail page. This block is intentionally clean so later it can be fed by product descriptions from the database without redesign work.
                        </div>
                        <div class="tab-pane fade" id="detail-spec-pane" role="tabpanel" aria-labelledby="detail-spec-tab">
                            <div class="spec-grid">
                                <div><strong>Display</strong><span>6.3-inch Super Retina XDR</span></div>
                                <div><strong>Chip</strong><span>A18 Pro</span></div>
                                <div><strong>Storage</strong><span>128GB to 1TB</span></div>
                                <div><strong>Camera</strong><span>Pro triple camera system</span></div>
                            </div>
                        </div>
                        <div class="tab-pane fade" id="detail-warranty-pane" role="tabpanel" aria-labelledby="detail-warranty-tab">
                            Reserve this section for official warranty policy, store support conditions, and return notes after the backend and content rules are finalized.
                        </div>
                        <div class="tab-pane fade" id="detail-shipping-pane" role="tabpanel" aria-labelledby="detail-shipping-tab">
                            Standard delivery, express delivery, and pickup information can live here in a stable reusable block.
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-block">
            <div class="container">
                <div class="section-heading">
                    <div>
                        <span class="eyebrow">Customer feedback</span>
                        <h2>Real reviews that can later come from completed orders</h2>
                    </div>
                    <a class="btn btn-app-outline" href="order-history.html">Purchased items</a>
                </div>
                <div class="detail-review-grid">
                    <div class="review-panel-stack">
                        <article class="review-summary-card">
                            <div class="review-card-head">
                                <div class="review-meta">
                                    <strong>4.8 out of 5</strong>
                                    <span>248 verified reviews across current iPhone 16 variants</span>
                                </div>
                                <span class="rating-pill">4.8 / 5</span>
                            </div>
                            <ul class="rating-breakdown">
                                <li>
                                    <span>5 star</span>
                                    <span class="rating-breakdown-bar"><span class="rating-breakdown-fill" style="width: 82%;"></span></span>
                                    <strong>204</strong>
                                </li>
                                <li>
                                    <span>4 star</span>
                                    <span class="rating-breakdown-bar"><span class="rating-breakdown-fill" style="width: 12%;"></span></span>
                                    <strong>29</strong>
                                </li>
                                <li>
                                    <span>3 star</span>
                                    <span class="rating-breakdown-bar"><span class="rating-breakdown-fill" style="width: 4%;"></span></span>
                                    <strong>10</strong>
                                </li>
                                <li>
                                    <span>2 star</span>
                                    <span class="rating-breakdown-bar"><span class="rating-breakdown-fill" style="width: 1%;"></span></span>
                                    <strong>3</strong>
                                </li>
                                <li>
                                    <span>1 star</span>
                                    <span class="rating-breakdown-bar"><span class="rating-breakdown-fill" style="width: 1%;"></span></span>
                                    <strong>2</strong>
                                </li>
                            </ul>
                        </article>

                        <div class="review-list">
                            <article class="review-card">
                                <div class="review-card-head">
                                    <div class="review-meta">
                                        <strong>Nguyen Minh Anh</strong>
                                        <span>Purchased Black Titanium / 256GB on Aug 3, 2026</span>
                                    </div>
                                    <span class="rating-pill">5 / 5</span>
                                </div>
                                <p>
                                    Camera upgrade is noticeable and the battery easily lasts a full workday. The store
                                    packaging also felt careful enough for a high-value hand-carried item.
                                </p>
                                <span class="status-badge status-delivered">Verified purchase</span>
                            </article>

                            <article class="review-card">
                                <div class="review-card-head">
                                    <div class="review-meta">
                                        <strong>Tran Bao Chau</strong>
                                        <span>Purchased Natural Titanium / 512GB on Jul 28, 2026</span>
                                    </div>
                                    <span class="rating-pill">4 / 5</span>
                                </div>
                                <p>
                                    Performance is excellent and the screen is bright outdoors. I only wish the box
                                    included clearer accessory recommendations for MagSafe charging.
                                </p>
                                <span class="status-badge status-in-stock">Published</span>
                            </article>

                            <article class="review-card">
                                <div class="review-card-head">
                                    <div class="review-meta">
                                        <strong>Le Quoc Minh</strong>
                                        <span>Purchased White Titanium / 256GB on Jul 20, 2026</span>
                                    </div>
                                    <span class="rating-pill">5 / 5</span>
                                </div>
                                <p>
                                    Smooth setup, great video quality, and the variant selector on this demo page would
                                    map nicely to real database-driven variants later.
                                </p>
                                <span class="status-badge status-processing">Helpful review</span>
                            </article>
                        </div>
                    </div>

                    <aside class="review-form-card">
                        <div class="review-form-head">
                            <h3>Write feedback</h3>
                            <p>Simple UI placeholder for the post-purchase review flow.</p>
                        </div>
                        <form action="submit-feedback" method="post" name="productFeedbackForm" class="field-grid">
                            <div>
                                <label class="form-label" for="feedback-rating">Rating</label>
                                <select id="feedback-rating" class="form-select" name="rating">
                                    <option>5 - Excellent</option>
                                    <option>4 - Good</option>
                                    <option>3 - Average</option>
                                    <option>2 - Poor</option>
                                    <option>1 - Very poor</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="feedback-order-code">Order reference</label>
                                <input id="feedback-order-code" class="form-control" type="text" name="orderCode" placeholder="AOS-240811">
                            </div>
                            <div>
                                <label class="form-label" for="feedback-title">Review title</label>
                                <input id="feedback-title" class="form-control" type="text" name="title" placeholder="What stood out most?">
                            </div>
                            <div>
                                <label class="form-label" for="feedback-comment">Your feedback</label>
                                <textarea id="feedback-comment" class="form-control" name="comment" rows="6" placeholder="Describe product quality, packaging, delivery impression, or after-sales experience."></textarea>
                            </div>
                            <button class="btn btn-app-primary w-100" type="submit">Submit feedback</button>
                        </form>
                    </aside>
                </div>
            </div>
        </section>

        <section class="section-block">
            <div class="container">
                <div class="section-heading">
                    <div>
                        <span class="eyebrow">Related products</span>
                        <h2>More items from the same browsing flow</h2>
                    </div>
                    <a class="btn btn-app-outline" href="products.html">Back to catalog</a>
                </div>
                <div class="row g-4 related-grid">
                    <div class="col-md-6 col-xl-3">
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
                    <div class="col-md-6 col-xl-3">
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
                                <p>46mm / Midnight</p>
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
                    <div class="col-md-6 col-xl-3">
                        <article class="product-card">
                            <div class="product-card-media">
                                <span class="app-badge badge-sale">Bundle</span>
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
                                </div>
                                <div class="product-actions">
                                    <a class="btn btn-app-outline w-100" href="product-detail.html">View detail</a>
                                    <button class="btn btn-app-primary w-100" type="button">Add to cart</button>
                                </div>
                            </div>
                        </article>
                    </div>
                    <div class="col-md-6 col-xl-3">
                        <article class="product-card">
                            <div class="product-card-media">
                                <img src="assets/images/mac-card.svg" alt="MacBook Air M4">
                            </div>
                            <div class="product-card-body">
                                <div class="product-meta">
                                    <span class="status-badge status-low-stock">Low stock</span>
                                    <button class="wishlist-button" type="button">Save</button>
                                </div>
                                <h3>MacBook Air M4</h3>
                                <p>13-inch / Silver</p>
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
                        <small>Product detail / Phase 2</small>
                    </span>
                </a>
                <p class="footer-copy">
                    Product detail layout with reusable gallery and variant sections that stay easy to migrate into JSP.
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
                <h3 class="footer-title">Future pages</h3>
                <ul class="footer-links">
                    <li><a href="cart.html">Cart</a></li>
                    <li><a href="checkout.html">Checkout</a></li>
                    <li><a href="order-history.html">Order History</a></li>
                </ul>
            </div>
            <div>
                <h3 class="footer-title">Newsletter</h3>
                <form action="subscribe-newsletter" method="post" name="newsletterForm" class="footer-form">
                    <label class="visually-hidden" for="detail-newsletter">Email address</label>
                    <input id="detail-newsletter" class="form-control" type="email" name="email" placeholder="Email address">
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

