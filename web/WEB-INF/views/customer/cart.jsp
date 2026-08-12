<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- If using Tomcat 10+/Jakarta EE, change uri "http://java.sun.com/jsp/jstl/..." -> "jakarta.tags.core" / "jakarta.tags.fmt" --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop | Cart</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">
    <!-- Site header -->
    <header class="site-header">
        <div class="topbar">
            <div class="container topbar-inner">
                <p class="topbar-note">Your cart - update quantities or remove items right here.</p>
                <ul class="topbar-links">
                    <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/products.html">Continue Shopping</a></li>
                    <li><a href="${pageContext.request.contextPath}/checkout.html">Checkout</a></li>
                </ul>
            </div>
        </div>
        <div class="container header-main">
            <a class="brand" href="${pageContext.request.contextPath}/index.html" aria-label="Apple Online Shop">
                <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg" alt="AOS mark">
                <span>
                    <strong>AOS Template</strong>
                    <small>Shopping Cart</small>
                </span>
            </a>
            <form class="header-search" action="${pageContext.request.contextPath}/products.html" method="get">
                <label class="visually-hidden" for="cart-search-input">Search products</label>
                <input id="cart-search-input" class="form-control" type="search" name="keyword" placeholder="Search products">
                <button class="btn btn-app-primary" type="submit">Search</button>
            </form>
            <div class="header-actions">
                <div class="dropdown">
                    <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        Account
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile.html">Profile</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/order-history.html">My Orders</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/wishlist.html">Wishlist</a></li>
                    </ul>
                </div>
                <a class="cart-link" href="${pageContext.request.contextPath}/cart" aria-label="View cart">
                    <span>Cart</span>
                    <span class="cart-count" data-cart-badge>${cartItemCount}</span>
                </a>
            </div>
        </div>
    </header>

    <main>
        <section class="section-block">
            <div class="container">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.html">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Cart</li>
                    </ol>
                </nav>
                <div class="store-page-heading">
                    <div>
                        <span class="eyebrow">Cart</span>
                        <h1>Your selected Apple products</h1>
                        <p>Discounts and shipping fees will be calculated at checkout.</p>
                    </div>
                    <div class="store-heading-meta">
                        <strong>${cartItemCount}</strong>
                        <span>items in cart</span>
                    </div>
                </div>

                <c:if test="${not empty sessionScope.flashError}">
                    <div class="alert alert-danger">${sessionScope.flashError}</div>
                    <c:remove var="flashError" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.flashSuccess}">
                    <div class="alert alert-success">${sessionScope.flashSuccess}</div>
                    <c:remove var="flashSuccess" scope="session"/>
                </c:if>
                <c:if test="${not empty requestScope.flashError}">
                    <div class="alert alert-danger">${requestScope.flashError}</div>
                </c:if>
            </div>
        </section>

        <section class="section-block section-soft">
            <div class="container">

                <c:choose>
                    <%-- ================= CART HAS ITEMS ================= --%>
                    <c:when test="${not empty cartItems}">
                        <div class="cart-layout">
                            <div class="cart-filled">
                                <div class="cart-list-card">
                                    <div class="cart-list-head">
                                        <div>
                                            <h2>Cart Items</h2>
                                            <p>Change quantity or remove products you no longer want.</p>
                                        </div>
                                        <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/products.html">Continue shopping</a>
                                    </div>

                                    <c:forEach var="item" items="${cartItems}">
                                        <article class="cart-item">
                                            <div class="cart-item-media">
                                                <img src="${pageContext.request.contextPath}${not empty item.imageUrl ? item.imageUrl : '/assets/images/iphone-card.svg'}"
                                                     alt="${item.productName}">
                                            </div>
                                            <div class="cart-item-body">
                                                <div class="cart-item-main">
                                                    <div>
                                                        <h3>${item.productName}</h3>
                                                        <p>
                                                            ${item.variantLabel}
                                                            <c:if test="${not empty item.addonName}">
                                                                &middot; Add-on: ${item.addonName}
                                                            </c:if>
                                                        </p>
                                                        <c:if test="${item.stockQuantity <= 0}">
                                                            <p class="text-danger">This product is out of stock, please remove it from your cart.</p>
                                                        </c:if>
                                                    </div>
                                                    <form action="${pageContext.request.contextPath}/cart/remove" method="post">
                                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                                        <button class="btn btn-app-ghost btn-sm" type="submit">Remove</button>
                                                    </form>
                                                </div>
                                                <div class="cart-item-meta">
                                                    <span>Unit price: <strong><fmt:formatNumber value="${item.effectiveUnitPrice}" pattern="#,##0"/> VND</strong></span>

                                                    <form class="quantity-control" action="${pageContext.request.contextPath}/cart/update" method="post">
                                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                                        <input type="number" name="quantity" value="${item.quantity}"
                                                               min="1" max="${item.stockQuantity}">
                                                        <button type="submit" class="btn btn-app-outline btn-sm">Update</button>
                                                    </form>

                                                    <span>Subtotal: <strong><fmt:formatNumber value="${item.subtotal}" pattern="#,##0"/> VND</strong></span>
                                                </div>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </div>

                            <aside class="cart-summary-card">
                                <div class="summary-card-head">
                                    <h2>Order Summary</h2>
                                    <p>Voucher codes are applied at checkout.</p>
                                </div>

                                <div class="summary-lines">
                                    <div class="summary-row">
                                        <span>Items</span>
                                        <strong>${cartItemCount}</strong>
                                    </div>
                                    <div class="summary-row">
                                        <span>Subtotal</span>
                                        <strong><fmt:formatNumber value="${cartSubtotal}" pattern="#.##"/> $</strong>
                                    </div>
                                    <div class="summary-row">
                                        <span>Shipping</span>
                                        <strong>Calculated at checkout</strong>
                                    </div>
                                </div>

                                <div class="summary-total">
                                    <span>Subtotal</span>
                                    <strong><fmt:formatNumber value="${cartSubtotal}" pattern="#,##0"/> VND</strong>
                                </div>

                                <div class="summary-actions">
                                    <a class="btn btn-app-primary w-100" href="${pageContext.request.contextPath}/checkout.html">Proceed to checkout</a>
                                    <a class="btn btn-app-secondary w-100" href="${pageContext.request.contextPath}/products.html">Continue shopping</a>
                                </div>
                            </aside>
                        </div>
                    </c:when>

                    <%-- ================= EMPTY CART ================= --%>
                    <c:otherwise>
                        <div class="empty-cart-panel">
                            <span class="eyebrow">Empty cart</span>
                            <h2>Your cart is currently empty</h2>
                            <p>Pick something you like and add it to your cart.</p>
                            <div class="hero-actions">
                                <a class="btn btn-app-primary" href="${pageContext.request.contextPath}/products.html">Browse products</a>
                                <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/index.html">Back to home</a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="container footer-bottom">
            <small>&copy; <span data-current-year></span> Apple Online Shop.</small>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>

