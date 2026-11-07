# ShopLite (demo app)

A tiny checkout pricing service used as the "product" in the Support-to-Ship Bridge demo.
It has **no dependencies**. You only need Node 18 or later.

```bash
npm test                                                          # run the test suite
node scripts/quote.js --region CA --coupon SAVE20 --item 120x1    # reproduce a checkout
```

- `src/pricing.js` contains the pricing logic.
- `docs/pricing-policy.md` is the customer-facing policy, the source of truth.
- `docs/support-faq.md` is what the support team answers from.

> It has two pricing bugs planted on purpose, and customers report them in the sample tickets.
> The agents in the Switch rooms find them, fix them and close the loop with the customer.
