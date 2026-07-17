<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="../common/header.jsp" />
        <title>Tùy chỉnh Bánh của bạn</title>
        <!-- Elegant Serif Font for Artisan Titles -->
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,600;1,600&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/customCake.css">
        <style>
            /* Adjust the 90px value up or down depending on your actual header height */
            .page-wrapper {
                padding-top: 100px !important;
                margin-top: 0 !important;
            }
            
            /* Custom Toast Notification */
            .cz-toast {
                position: fixed;
                top: 80px;
                right: -350px;
                width: 320px;
                background-color: #fff;
                color: #333;
                padding: 16px 20px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                display: flex;
                align-items: center;
                gap: 12px;
                z-index: 9999;
                transition: right 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
                font-family: 'Outfit', sans-serif;
                border-left: 5px solid #10b981;
            }
            .cz-toast.show {
                right: 20px;
            }
            .cz-toast.error {
                border-left-color: #ef4444;
            }
            .cz-toast-icon {
                font-size: 20px;
            }
            .cz-toast.success .cz-toast-icon {
                color: #10b981;
            }
            .cz-toast.error .cz-toast-icon {
                color: #ef4444;
            }
            .cz-toast-message {
                font-size: 14px;
                font-weight: 500;
                line-height: 1.4;
            }
        </style>
    </head>
    <body>
        <div class="page-wrapper">
            <jsp:include page="../common/navbar.jsp" />

            <!-- Page Hero Title -->
        <div class="studio-hero">
            <h1 class="studio-hero-title">Thiết kế bánh kem sinh nhật của riêng bạn</h1>
            <p class="studio-hero-desc">Tự do sáng tạo hương vị, số lượng tầng bánh và trang trí mặt bánh theo phong cách của riêng bạn.</p>
        </div>

        <main class="custom-cake-main">
                <div class="studio-container">

                    <!-- Left Column -->
                    <div class="column-wrapper">
                        <div class="column-content">

                            <!-- Side View Card -->
                            <div class="white-card">
                                <h2 class="artisan-title">Mặt cắt tầng bánh</h2>
                                <div class="layer-stack-container" id="layerStack">
                                    <!-- Layers injected via JS -->
                                </div>
                                <!-- Vector Cake Stand Graphic -->
                                <div class="cake-stand">
                                    <div class="stand-plate"></div>
                                    <div class="stand-base"></div>
                                </div>
                            </div>

                            <!-- Top View Card -->
                            <div class="white-card">
                                <h2 class="artisan-title">Trang trí mặt bánh</h2>
                                <div class="canvas-wrapper">
                                    <canvas id="cakeDrawingCanvas" width="300" height="300"></canvas>
                                </div>

                                <!-- 2-Column Pill Grid -->
                                <div class="tool-grid">
                                    <button class="tool-btn swatch-btn" data-color="#5C3A21">
                                        <span class="color-dot choco"></span> Sô-cô-la
                                    </button>
                                    <button class="tool-btn swatch-btn" data-color="#E8A7A1">
                                        <span class="color-dot straw"></span> Dâu tây
                                    </button>
                                    <button class="tool-btn swatch-btn active" data-color="#F4EAD4">
                                        <span class="color-dot vanilla"></span> Vani
                                    </button>
                                    <button class="tool-btn swatch-btn" data-color="#8F9E7B">
                                        <span class="color-dot matcha"></span> Trà xanh
                                    </button>
                                    <button class="tool-btn" id="eraserBtn">
                                        🧹 Tẩy
                                    </button>
                                    <button class="tool-btn" id="clearBtn">
                                        🗑 Xóa tất cả
                                    </button>
                                </div>

                                <div class="brush-thickness" style="margin-top: 24px;">
                                    <label for="brushSize" style="font-weight: 500; color: #4A5568; display: block; margin-bottom: 12px;">Độ dày nét cọ:</label>
                                    <input type="range" id="brushSize" min="2" max="20" value="5">
                                </div>
                            </div>

                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="column-wrapper">
                        <div class="column-content">

                            <!-- Config Card -->
                            <div class="white-card">

                                <!-- Size -->
                                <div class="control-group">
                                    <label class="control-label">Kích thước đế bánh</label>
                                    <select class="premium-input" id="sizeSelect" onchange="updatePrice()">
                                        <option value="16">16cm (Nhỏ, 4-6 người)</option>
                                        <option value="20">20cm (Vừa, 6-8 người)</option>
                                        <option value="24">24cm (Lớn, >8 người)</option>
                                    </select>
                                </div>

                                <!-- Layer Count -->
                                <div class="control-group">
                                    <label class="control-label">Số lượng tầng (2-5)</label>
                                    <div class="layer-adjuster-modern">
                                        <button type="button" onclick="changeLayerCount(-1)">−</button>
                                        <input type="text" id="layerCount" value="3" readonly class="premium-input">
                                        <button type="button" onclick="changeLayerCount(1)">+</button>
                                    </div>
                                </div>

                                <!-- Flavor Matrix -->
                                <div class="control-group">
                                    <label class="control-label">Hương vị từng tầng</label>
                                    <div class="flavor-matrix" id="flavorMatrix">
                                        <!-- Matrix rows injected via JS -->
                                    </div>
                                </div>

                                <!-- Greeting -->
                                <div class="control-group" style="margin-bottom: 0;">
                                    <label class="control-label">Thông điệp trang trí (Tối đa 30 ký tự)</label>
                                    <input type="text" class="premium-input" id="greetingText" maxlength="30" placeholder="Ví dụ: Chúc mừng sinh nhật...">
                                </div>
                            </div>

                            <!-- Order Summary Card -->
                            <div class="summary-card">
                                <h3 class="summary-title">Tóm tắt đơn hàng</h3>
                                <div class="summary-line">
                                    <span class="summary-label">Giá cơ bản</span>
                                    <span class="summary-value" id="basePriceDisplay">0₫</span>
                                </div>
                                <div class="summary-line">
                                    <span class="summary-label">Phụ phí hương vị</span>
                                    <span class="summary-value" id="flavorPriceDisplay">0₫</span>
                                </div>
                                <div class="summary-divider"></div>
                                <div class="summary-line total-line">
                                    <span class="summary-label">Tổng cộng</span>
                                    <span class="summary-value-total" id="totalPriceDisplay">0₫</span>
                                </div>
                                <button class="checkout-btn-modern" type="button" onclick="addToCart()">THÊM VÀO GIỎ HÀNG</button>
                            </div>

                        </div>
                    </div>

                </div>
            </main>

            <jsp:include page="../common/footer.jsp" />
        </div>

        <jsp:include page="../common/scripts.jsp" />

        <script>
            // State
            let state = {
                size: 16,
                layers: 3,
                flavors: ["vanilla", "vanilla", "vanilla"],
                price: 0
            };

            const flavorColors = {
                "vanilla": "#F4EAD4", // Warm Buttery Cream
                "chocolate": "#5C3A21", // Rich Matte Cocoa
                "strawberry": "#E8A7A1", // Pastel Rosé Pink
                "matcha": "#8F9E7B" // Natural Muted Matcha
            };

            // Initialize UI
            document.addEventListener("DOMContentLoaded", () => {
                renderFlavorMatrix();
                renderLayerStack();
                updatePrice();
                initCanvas();
            });

            function changeLayerCount(delta) {
                let newVal = state.layers + delta;
                if (newVal >= 2 && newVal <= 5) {
                    state.layers = newVal;
                    document.getElementById('layerCount').value = newVal;

                    // Adjust flavors array
                    while (state.flavors.length < state.layers) {
                        state.flavors.push("vanilla");
                    }
                    if (state.flavors.length > state.layers) {
                        state.flavors = state.flavors.slice(0, state.layers);
                    }

                    renderFlavorMatrix();
                    renderLayerStack();
                    updatePrice();
                }
            }

            function renderFlavorMatrix() {
                const matrix = document.getElementById('flavorMatrix');
                matrix.innerHTML = '';
                for (let i = 0; i < state.layers; i++) {
                    const row = document.createElement('div');
                    row.className = 'flavor-row';

                    const label = document.createElement('label');
                    label.innerText = 'Tầng ' + (i + 1) + (i === 0 ? ' (Đáy)' : (i === state.layers - 1 ? ' (Đỉnh)' : ''));

                    const select = document.createElement('select');
                    select.className = 'premium-input';
                    select.onchange = (e) => {
                        state.flavors[i] = e.target.value;
                        renderLayerStack();
                        updatePrice();
                    };

                    const options = [
                        {val: 'vanilla', text: 'Vani Truyền Thống'},
                        {val: 'chocolate', text: 'Sô-cô-la Đen'},
                        {val: 'strawberry', text: 'Dâu Tây Mềm'},
                        {val: 'matcha', text: 'Trà Xanh Matcha'}
                    ];

                    options.forEach(opt => {
                        const option = document.createElement('option');
                        option.value = opt.val;
                        option.innerText = opt.text;
                        if (state.flavors[i] === opt.val)
                            option.selected = true;
                        select.appendChild(option);
                    });

                    row.appendChild(label);
                    row.appendChild(select);
                    matrix.appendChild(row);
                }
            }

            function renderLayerStack() {
                const stack = document.getElementById('layerStack');
                stack.innerHTML = '';

                // Render layers from bottom (index 0) to top (index length-1)
                for (let i = 0; i < state.layers; i++) {
                    const layer = document.createElement('div');
                    layer.className = 'cake-layer';
                    layer.style.backgroundColor = flavorColors[state.flavors[i]];
                    stack.appendChild(layer);
                }
                
                // Update Canvas Background to match top layer
                const canvas = document.getElementById('cakeDrawingCanvas');
                if (canvas) {
                    canvas.style.backgroundColor = flavorColors[state.flavors[state.layers - 1]];
                }
            }

            function updatePrice() {
                const sizeInput = document.getElementById('sizeSelect');
                state.size = sizeInput ? parseInt(sizeInput.value) : 16;

                // Base price logic based on size
                let base = 0;
                if (state.size === 16)
                    base = 150000;
                else if (state.size === 20)
                    base = 250000;
                else if (state.size === 24)
                    base = 350000;

                // Add price per layer type
                let layerPrice = 0;
                state.flavors.forEach(f => {
                    if (f === 'vanilla')
                        layerPrice += 50000;
                    else if (f === 'chocolate')
                        layerPrice += 65000;
                    else if (f === 'strawberry')
                        layerPrice += 60000;
                    else if (f === 'matcha')
                        layerPrice += 70000;
                });

                state.price = base + layerPrice;

                document.getElementById('basePriceDisplay').innerText = base.toLocaleString('vi-VN') + '₫';
                document.getElementById('flavorPriceDisplay').innerText = layerPrice.toLocaleString('vi-VN') + '₫';
                document.getElementById('totalPriceDisplay').innerText = state.price.toLocaleString('vi-VN') + '₫';
            }

            function showToast(message, type = 'success') {
                let toast = document.getElementById('cz-toast');
                if (!toast) {
                    toast = document.createElement('div');
                    toast.id = 'cz-toast';
                    document.body.appendChild(toast);
                }
                toast.className = 'cz-toast ' + type;
                const iconHtml = type === 'success' ? '<i class="fa-solid fa-circle-check"></i>' : '<i class="fa-solid fa-circle-exclamation"></i>';
                toast.innerHTML = '<div class="cz-toast-icon">' + iconHtml + '</div><div class="cz-toast-message">' + message + '</div>';
                
                // Trigger reflow
                void toast.offsetWidth;
                toast.classList.add('show');
                
                setTimeout(() => {
                    toast.classList.remove('show');
                }, 3000);
            }

            function addToCart() {
            const canvas = document.getElementById('cakeDrawingCanvas');
            
            // Create composite image with background color
            const tempCanvas = document.createElement('canvas');
            tempCanvas.width = canvas.width;
            tempCanvas.height = canvas.height;
            const tempCtx = tempCanvas.getContext('2d');
            
            // Draw circle background
            const topFlavor = state.flavors[state.layers - 1];
            tempCtx.fillStyle = flavorColors[topFlavor];
            tempCtx.beginPath();
            tempCtx.arc(tempCanvas.width/2, tempCanvas.height/2, tempCanvas.width/2, 0, Math.PI * 2);
            tempCtx.fill();
            
            // Draw user drawing on top
            tempCtx.drawImage(canvas, 0, 0);
            
            const canvasImageData = tempCanvas.toDataURL('image/png');
            const greetingText = document.getElementById('greetingText').value.trim();
            const sizeSelect = document.getElementById('sizeSelect');
            const cakeSize = sizeSelect ? sizeSelect.value : '16';

            const params = new URLSearchParams();
            params.append('canvasImageData', canvasImageData);
            params.append('greetingText', greetingText);
            params.append('cakeSize', cakeSize);
            params.append('layerCount', String(state.layers));
            params.append('calculatedPrice', String(state.price));
            state.flavors.forEach((flavor, index) => {
                params.append('flavor_' + (index + 1), flavor);
            });

            const btn = document.querySelector('.checkout-btn-modern');
            btn.disabled = true;
            btn.textContent = 'Đang lưu...';

            fetch('<%= request.getContextPath() %>/custom-cake', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast('Thêm vào giỏ hàng thành công!', 'success');
                } else {
                    showToast(data.message, 'error');
                }
            })
            .catch(err => {
                console.error(err);
                showToast('Lỗi kết nối. Vui lòng thử lại.', 'error');
            })
            .finally(() => {
                btn.disabled = false;
                btn.textContent = 'THÊM VÀO GIỎ HÀNG 🛒';
            });
        }

            // Canvas Drawing Logic
            function initCanvas() {
                const canvas = document.getElementById('cakeDrawingCanvas');
                const ctx = canvas.getContext('2d');
                let isDrawing = false;
                let currentBrushColor = '#F4EAD4';
                let currentBrushSize = 5;

                ctx.globalCompositeOperation = 'source-over';

                function updateCursor() {
                    const size = Math.max(parseInt(currentBrushSize), 4);
                    const half = size / 2;
                    const r = Math.max((size - 1) / 2, 0.5);
                    const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size + '"><circle cx="' + half + '" cy="' + half + '" r="' + r + '" fill="none" stroke="black" stroke-width="1" opacity="0.5"/></svg>';
                    canvas.style.cursor = 'url("data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg) + '") ' + half + ' ' + half + ', crosshair';
                }
                updateCursor();

                // Tools setup
                const toolBtns = document.querySelectorAll('.tool-btn');
                const swatchBtns = document.querySelectorAll('.swatch-btn');
                const eraserBtn = document.getElementById('eraserBtn');
                const clearBtn = document.getElementById('clearBtn');
                const brushSizeInput = document.getElementById('brushSize');

                // Handle Swatches
                swatchBtns.forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        toolBtns.forEach(s => s.classList.remove('active'));
                        const target = e.currentTarget;
                        target.classList.add('active');
                        currentBrushColor = target.getAttribute('data-color');
                        ctx.globalCompositeOperation = 'source-over';
                    });
                });

                // Handle Eraser
                eraserBtn.addEventListener('click', () => {
                    toolBtns.forEach(s => s.classList.remove('active'));
                    eraserBtn.classList.add('active');
                    ctx.globalCompositeOperation = 'destination-out';
                });

                // Handle Clear
                clearBtn.addEventListener('click', () => {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                });

                // Handle Brush Size
                brushSizeInput.addEventListener('input', (e) => {
                    currentBrushSize = e.target.value;
                    updateCursor();
                });

                // Drawing Functions
                function startPosition(e) {
                    isDrawing = true;
                    draw(e);
                }

                function endPosition() {
                    isDrawing = false;
                    ctx.beginPath();
                }

                function draw(e) {
                    if (!isDrawing)
                        return;

                    const rect = canvas.getBoundingClientRect();
                    const x = e.clientX - rect.left;
                    const y = e.clientY - rect.top;

                    ctx.lineWidth = currentBrushSize;
                    ctx.lineCap = 'round';
                    ctx.strokeStyle = currentBrushColor;

                    ctx.lineTo(x, y);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(x, y);
                }

                // Mouse Events
                canvas.addEventListener('mousedown', startPosition);
                canvas.addEventListener('mouseup', endPosition);
                canvas.addEventListener('mousemove', draw);
                canvas.addEventListener('mouseleave', endPosition);

                // Touch Events
                canvas.addEventListener('touchstart', (e) => {
                    e.preventDefault();
                    const touch = e.touches[0];
                    const mouseEvent = new MouseEvent("mousedown", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, {passive: false});

                canvas.addEventListener('touchend', (e) => {
                    e.preventDefault();
                    const mouseEvent = new MouseEvent("mouseup", {});
                    canvas.dispatchEvent(mouseEvent);
                }, {passive: false});

                canvas.addEventListener('touchmove', (e) => {
                    e.preventDefault();
                    const touch = e.touches[0];
                    const mouseEvent = new MouseEvent("mousemove", {
                        clientX: touch.clientX,
                        clientY: touch.clientY
                    });
                    canvas.dispatchEvent(mouseEvent);
                }, {passive: false});
            }
        </script>
    </body>
</html>
