# Phase 3 - POS Feature Test Cases

**Feature:** Point of Sale (POS)
**Status:** ✅ Ready for Testing
**Date:** November 13, 2025

---

## Test Environment Setup

### Prerequisites
- [ ] Backend API running on port 3000
- [ ] Database seeded with test data
- [ ] Flutter app running on emulator/device
- [ ] Logged in with valid employee credentials

### Test Data
**Discount Codes:**
- `WELCOME10` - 10% percentage discount
- `STUDENT20` - R$ 20.00 fixed discount

**Test Products:**
- Popcorn - Various stock levels
- Candy - Various stock levels
- Soda - Various stock levels

---

## Test Cases

### TC-POS-001: Start POS Module
**Priority:** High
**Type:** Smoke Test

**Steps:**
1. Navigate to Dashboard
2. Click "Ponto de Venda" quick action
3. Observe POS page loads

**Expected Results:**
- ✅ POS page displays with product grid
- ✅ "Iniciar POS" or product grid visible
- ✅ No error messages

**Status:** [ ]

---

### TC-POS-002: Load Products
**Priority:** High
**Type:** Functional

**Steps:**
1. Open POS page
2. Observe product grid

**Expected Results:**
- ✅ All active products displayed in 2-column grid
- ✅ Each product shows: name, price, category, stock badge
- ✅ Stock badges show correct quantities
- ✅ Color coding: Green (>10), Orange (1-10), Red (0)

**Status:** [ ]

---

### TC-POS-003: Create New Sale
**Priority:** High
**Type:** Functional

**Steps:**
1. Click "Nova Venda" button
2. Observe sale creation

**Expected Results:**
- ✅ Active sale indicator appears (green banner)
- ✅ Temporary sale ID displayed (LOCAL_xxxxx)
- ✅ Shopping cart panel shown
- ✅ Cart shows "0 itens"

**Status:** [ ]

---

### TC-POS-004: Add Product to Cart
**Priority:** High
**Type:** Functional

**Steps:**
1. Create new sale
2. Note product stock (e.g., Popcorn - 10 units)
3. Click product card
4. Observe cart updates

**Expected Results:**
- ✅ Product added to cart with quantity 1
- ✅ Stock badge decrements to 9
- ✅ Cart shows "1 item"
- ✅ Item details displayed: name, quantity, price, total
- ✅ Subtotal calculated correctly
- ✅ NO premature success toast

**Status:** [ ]

---

### TC-POS-005: Stock Badge Real-Time Updates
**Priority:** High
**Type:** Functional

**Steps:**
1. Create new sale
2. Product has 5 units in stock
3. Click product 3 times
4. Observe badge changes

**Expected Results:**
- ✅ Badge shows: 5 → 4 → 3 → 2
- ✅ Cart has 3 items
- ✅ Badge color changes if threshold crossed

**Status:** [ ]

---

### TC-POS-006: Client-Side Stock Validation
**Priority:** High
**Type:** Functional

**Steps:**
1. Create new sale
2. Product has 5 units
3. Click product 5 times (add all stock)
4. Try to click product again

**Expected Results:**
- ✅ Stock badge shows 0 (red)
- ✅ Cart has 5 items
- ✅ Error snackbar: "Produto sem estoque disponível"
- ✅ Product NOT added to cart
- ✅ State returns to normal immediately

**Status:** [ ]

---

### TC-POS-007: Remove Item from Cart
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with 3 items in cart
2. Note stock badge before removal
3. Click red trash icon on one item
4. Observe changes

**Expected Results:**
- ✅ Item removed from cart
- ✅ Cart count decreases by 1
- ✅ Stock badge increments by removed quantity
- ✅ Totals recalculate correctly
- ✅ No API call made (instant)

**Status:** [ ]

---

### TC-POS-008: Apply Discount - WELCOME10 (10%)
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with items totaling R$ 100.00
2. Click "Aplicar Desconto" button
3. Observe dialog opens
4. Verify keyboard appears automatically
5. Verify text field has visible border
6. Type "WELCOME10"
7. Click "Aplicar"
8. Observe discount application

**Expected Results:**
- ✅ Dialog opens with auto-focused text field
- ✅ Text field has 2px visible border
- ✅ Keyboard appears automatically
- ✅ Background fill color visible
- ✅ Discount validated with backend
- ✅ Discount amount: R$ 10.00 (10%)
- ✅ New grand total: R$ 90.00
- ✅ Discount code shown in cart
- ✅ Discount amount displayed

**Status:** [ ]

---

### TC-POS-009: Apply Discount - STUDENT20 (Fixed)
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with items totaling R$ 100.00
2. Click "Aplicar Desconto"
3. Type "STUDENT20"
4. Click "Aplicar"

**Expected Results:**
- ✅ Discount validated
- ✅ Discount amount: R$ 20.00 (fixed)
- ✅ New grand total: R$ 80.00
- ✅ Discount code shown in cart

**Status:** [ ]

---

### TC-POS-010: Invalid Discount Code
**Priority:** Medium
**Type:** Negative

**Steps:**
1. Create sale with items
2. Click "Aplicar Desconto"
3. Type "INVALID123"
4. Click "Aplicar"

**Expected Results:**
- ✅ Error snackbar appears
- ✅ Message: "Código de desconto não encontrado"
- ✅ No discount applied
- ✅ Totals unchanged
- ✅ State recovers to normal

**Status:** [ ]

---

### TC-POS-011: Add Single Payment (Cash)
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with R$ 50.00 total
2. Click "Adicionar Pagamento" button
3. Observe dialog layout
4. Select "Dinheiro" (Cash)
5. Enter R$ 50.00
6. Click "Adicionar"

**Expected Results:**
- ✅ Dialog shows remaining amount prominently (column layout)
- ✅ Orange background box for amount
- ✅ Payment methods as ChoiceChips (not segmented)
- ✅ Each chip shows icon + label
- ✅ No checkmarks on chips
- ✅ Selected chip turns orange
- ✅ Payment added to list
- ✅ Payment shows method and amount
- ✅ Remaining amount: R$ 0.00
- ✅ "Finalizar Venda" button enabled

**Status:** [ ]

---

### TC-POS-012: Add Multiple Payments
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with R$ 100.00 total
2. Add payment: Cash R$ 50.00
3. Verify remaining: R$ 50.00
4. Add payment: Card R$ 30.00, auth code "123456"
5. Verify remaining: R$ 20.00
6. Add payment: PIX R$ 20.00
7. Verify remaining: R$ 0.00

**Expected Results:**
- ✅ All three payments listed
- ✅ Each payment shows method and amount
- ✅ Remaining amount updates after each payment
- ✅ Final remaining: R$ 0.00
- ✅ "Finalizar Venda" enabled

**Status:** [ ]

---

### TC-POS-013: Remove Payment
**Priority:** Medium
**Type:** Functional

**Steps:**
1. Create sale with R$ 50.00 total
2. Add payment: Cash R$ 50.00
3. Click red trash icon on payment
4. Observe changes

**Expected Results:**
- ✅ Payment removed from list
- ✅ Remaining amount: R$ 50.00
- ✅ "Finalizar Venda" disabled
- ✅ No API call (instant/local)

**Status:** [ ]

---

### TC-POS-014: Finalize Sale - Happy Path
**Priority:** Critical
**Type:** End-to-End

**Steps:**
1. Create new sale
2. Add 3 products (total: R$ 85.00)
3. Apply discount WELCOME10 (R$ 8.50 off)
4. New total: R$ 76.50
5. Add payment: Cash R$ 76.50
6. Click "Finalizar Venda"
7. Wait for processing
8. Observe completion

**Expected Results:**
- ✅ Processing indicator appears
- ✅ Sale created on backend
- ✅ All items added to backend sale
- ✅ Discount applied on backend
- ✅ Payment registered on backend
- ✅ Sale finalized successfully
- ✅ Success dialog appears
- ✅ Sale receipt/summary displayed
- ✅ Can start new sale or close

**Status:** [ ]

---

### TC-POS-015: Finalize Sale - Validation (No Items)
**Priority:** High
**Type:** Negative

**Steps:**
1. Create new sale (empty cart)
2. Try to click "Finalizar Venda"

**Expected Results:**
- ✅ Button is disabled
- ✅ Cannot click button
- ✅ No API call made

**Status:** [ ]

---

### TC-POS-016: Finalize Sale - Validation (Incomplete Payment)
**Priority:** High
**Type:** Negative

**Steps:**
1. Create sale with R$ 100.00 total
2. Add payment: Cash R$ 50.00
3. Click "Finalizar Venda"

**Expected Results:**
- ✅ Error message appears
- ✅ Message shows: "Pagamento incompleto. Pago: R$ 50.00, Necessário: R$ 100.00"
- ✅ Sale not finalized
- ✅ State remains in progress
- ✅ Can add more payments

**Status:** [ ]

---

### TC-POS-017: Server-Side Stock Validation on Finalize
**Priority:** High
**Type:** Functional

**Prerequisites:** Requires concurrent sale simulation

**Steps:**
1. Create sale with product (2 units available)
2. Add 2 units to cart
3. Add payment
4. **BEFORE finalizing:** In database, reduce stock to 0
5. Click "Finalizar Venda"
6. Wait for backend processing

**Expected Results:**
- ✅ Backend detects stock conflict (409 status)
- ✅ Error message: "Estoque insuficiente. Os produtos foram atualizados."
- ✅ Products automatically reloaded
- ✅ Stock badges show updated quantities
- ✅ Sale remains in progress
- ✅ User can adjust cart with new stock info

**Status:** [ ]

---

### TC-POS-018: Cancel Sale
**Priority:** High
**Type:** Functional

**Steps:**
1. Create sale with items, discount, and partial payment
2. Click "Cancelar Venda" button
3. Observe confirmation dialog
4. Click "Cancelar Venda" in dialog

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ Dialog text: "Tem certeza que deseja cancelar esta venda?"
- ✅ Sale cancelled
- ✅ No backend API call
- ✅ Cart cleared
- ✅ Stock badges restored
- ✅ Returns to products loaded state
- ✅ "Nova Venda" button available

**Status:** [ ]

---

### TC-POS-019: Button Styling Consistency
**Priority:** Low
**Type:** Visual

**Steps:**
1. Create sale with items and payment
2. Observe all four action buttons

**Expected Results:**
- ✅ **Aplicar Desconto:** Orange outlined, full width, offer icon
- ✅ **Adicionar Pagamento:** Orange filled, full width, payment icon
- ✅ **Finalizar Venda:** Green filled, full width, check icon
- ✅ **Cancelar Venda:** Red outlined, full width, close icon
- ✅ All buttons same height/padding
- ✅ Consistent spacing between buttons

**Status:** [ ]

---

### TC-POS-020: Discount Dialog UI
**Priority:** Medium
**Type:** Visual/UX

**Steps:**
1. Create sale
2. Click "Aplicar Desconto"
3. Observe dialog details

**Expected Results:**
- ✅ Title: "Aplicar Desconto"
- ✅ Instruction text visible
- ✅ Text field auto-focused
- ✅ Keyboard appears automatically
- ✅ Border: 2px, clearly visible
- ✅ Border color changes on focus (primary color)
- ✅ Background filled (not transparent)
- ✅ Offer icon visible
- ✅ "Cancelar" and "Aplicar" buttons

**Status:** [ ]

---

### TC-POS-021: Payment Dialog UI
**Priority:** Medium
**Type:** Visual/UX

**Steps:**
1. Create sale with R$ 100.00 total
2. Click "Adicionar Pagamento"
3. Observe dialog layout

**Expected Results:**
- ✅ Title: "Registrar Pagamento"
- ✅ **Remaining amount in column layout** (not row)
- ✅ Text: "Valor Restante" above amount
- ✅ Amount large and centered
- ✅ Orange background box
- ✅ Payment methods as ChoiceChips (3 options)
- ✅ Each chip: icon + label (e.g., 💵 Dinheiro)
- ✅ No checkmarks on chips
- ✅ Selected chip highlighted orange
- ✅ Amount field with currency formatting
- ✅ Auth code field (optional)
- ✅ Compact spacing throughout

**Status:** [ ]

---

### TC-POS-022: Empty Cart State
**Priority:** Low
**Type:** Visual

**Steps:**
1. Open POS without creating sale
2. Observe cart panel

**Expected Results:**
- ✅ Cart header shows "Carrinho - 0 itens"
- ✅ Empty state message
- ✅ Icon displayed
- ✅ Text: "Sem venda ativa"
- ✅ Instruction: "Clique em 'Nova Venda' para começar"

**Status:** [ ]

---

### TC-POS-023: Product Out of Stock Display
**Priority:** Medium
**Type:** Visual

**Prerequisites:** Product with 0 stock

**Steps:**
1. Identify product with 0 stock
2. Observe product card

**Expected Results:**
- ✅ Stock badge shows 0
- ✅ Badge color: Red
- ✅ Product still visible (not hidden)
- ✅ Can still click but shows error

**Status:** [ ]

---

### TC-POS-024: Network Error Handling
**Priority:** High
**Type:** Error Handling

**Steps:**
1. Stop backend: `docker stop cinema_api`
2. Create sale
3. Add items
4. Add payment
5. Click "Finalizar Venda"

**Expected Results:**
- ✅ Processing indicator appears
- ✅ Error occurs during backend call
- ✅ Error message displayed
- ✅ Sale remains in progress
- ✅ Can retry after backend is back
6. Start backend: `docker start cinema_api`
7. Click "Finalizar Venda" again
- ✅ Sale completes successfully

**Status:** [ ]

---

### TC-POS-025: Discount Code Case Insensitivity
**Priority:** Low
**Type:** Functional

**Steps:**
1. Create sale
2. Apply discount with lowercase: "welcome10"

**Expected Results:**
- ✅ Code automatically converted to uppercase
- ✅ Discount validated and applied successfully

**Status:** [ ]

---

### TC-POS-026: Sale Complete Dialog
**Priority:** Medium
**Type:** Functional

**Steps:**
1. Complete a full sale
2. Observe success dialog

**Expected Results:**
- ✅ Dialog appears with sale summary
- ✅ Shows sale details (items, total, payments)
- ✅ Options: "Nova Venda" or "Fechar"
- ✅ Cannot dismiss by tapping outside
- ✅ "Nova Venda" starts new sale
- ✅ "Fechar" returns to products view

**Status:** [ ]

---

## Test Execution Summary

### Pass/Fail Criteria
- **Critical:** All test cases MUST pass
- **High Priority:** 95% pass rate required
- **Medium Priority:** 90% pass rate acceptable
- **Low Priority:** 80% pass rate acceptable

### Test Results Template

| TC ID | Test Case | Priority | Status | Notes |
|-------|-----------|----------|--------|-------|
| TC-POS-001 | Start POS Module | High | ⬜ | |
| TC-POS-002 | Load Products | High | ⬜ | |
| TC-POS-003 | Create New Sale | High | ⬜ | |
| TC-POS-004 | Add Product to Cart | High | ⬜ | |
| TC-POS-005 | Stock Badge Updates | High | ⬜ | |
| TC-POS-006 | Client Stock Validation | High | ⬜ | |
| TC-POS-007 | Remove Item | High | ⬜ | |
| TC-POS-008 | Discount WELCOME10 | High | ⬜ | |
| TC-POS-009 | Discount STUDENT20 | High | ⬜ | |
| TC-POS-010 | Invalid Discount | Medium | ⬜ | |
| TC-POS-011 | Single Payment | High | ⬜ | |
| TC-POS-012 | Multiple Payments | High | ⬜ | |
| TC-POS-013 | Remove Payment | Medium | ⬜ | |
| TC-POS-014 | Finalize Happy Path | Critical | ⬜ | |
| TC-POS-015 | Validation No Items | High | ⬜ | |
| TC-POS-016 | Incomplete Payment | High | ⬜ | |
| TC-POS-017 | Server Stock Validation | High | ⬜ | |
| TC-POS-018 | Cancel Sale | High | ⬜ | |
| TC-POS-019 | Button Styling | Low | ⬜ | |
| TC-POS-020 | Discount Dialog UI | Medium | ⬜ | |
| TC-POS-021 | Payment Dialog UI | Medium | ⬜ | |
| TC-POS-022 | Empty Cart State | Low | ⬜ | |
| TC-POS-023 | Out of Stock Display | Medium | ⬜ | |
| TC-POS-024 | Network Error | High | ⬜ | |
| TC-POS-025 | Code Case Insensitive | Low | ⬜ | |
| TC-POS-026 | Complete Dialog | Medium | ⬜ | |

---

## Bug Report Template

**Bug ID:** BUG-POS-XXX
**Test Case:** TC-POS-XXX
**Severity:** Critical/High/Medium/Low
**Priority:** P1/P2/P3/P4

**Description:**
[Brief description of the issue]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Environment:**
- Device: [Android Emulator/iOS Simulator/Physical]
- OS Version: [e.g., Android 13, iOS 16]
- App Version: [Phase 3]
- Backend Version: [Running on Docker]

**Screenshots/Logs:**
[Attach if applicable]

**Status:** Open/In Progress/Resolved/Closed

---

## Test Coverage Summary

### Features Tested
- ✅ Product listing and display
- ✅ Stock management (client-side)
- ✅ Stock validation (server-side)
- ✅ Sale creation (local)
- ✅ Add/remove items
- ✅ Discount code validation
- ✅ Discount calculation
- ✅ Payment management
- ✅ Multiple payment methods
- ✅ Sale finalization
- ✅ Sale cancellation
- ✅ Error handling
- ✅ UI/UX consistency

### Total Test Cases: 26
- Critical: 1
- High: 16
- Medium: 6
- Low: 3

---

**Test Execution Date:** ________________
**Tester:** ________________
**Overall Status:** ⬜ Pass / ⬜ Fail
**Notes:**

---

**End of Test Cases Document**
