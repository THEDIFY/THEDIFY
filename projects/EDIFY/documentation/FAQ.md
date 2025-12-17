# EDIFY - Frequently Asked Questions (FAQ)

Quick answers to common questions about EDIFY, the AI-powered education platform.

## Table of Contents

- [General Questions](#general-questions)
- [Technical Questions](#technical-questions)
- [Learning & Usage](#learning--usage)
- [Pricing & Subscriptions](#pricing--subscriptions)
- [Privacy & Security](#privacy--security)
- [For Educators](#for-educators)
- [Troubleshooting](#troubleshooting)

---

## General Questions

### What is EDIFY?

EDIFY is an enterprise-scale AI education platform that uses a novel Retrieval-Augmented Generation (RAG) approach to provide personalized learning experiences. It adapts to your skill level, learning goals, and pace, delivering sub-2-second responses with academic-grade citations.

### Who is EDIFY for?

- **Students:** K-12 through university seeking personalized tutoring
- **Professionals:** Lifelong learners upskilling in AI/ML and technology
- **Educators:** Teachers wanting to enhance student engagement
- **Institutions:** Schools and universities needing scalable solutions

### How is EDIFY different from ChatGPT or other AI chatbots?

| Feature | EDIFY | ChatGPT | Traditional Platforms |
|---------|-------|---------|----------------------|
| **Personalization** | Adapts to your skill level | Generic responses | One-size-fits-all |
| **Citations** | Academic-grade sources | Limited | None |
| **Learning Analytics** | Detailed progress tracking | None | Basic stats |
| **Curriculum Adaptation** | Dynamic adjustment | None | Static courses |
| **Response Speed** | <2 seconds | 3-7 seconds | N/A |

### Is EDIFY free?

EDIFY offers multiple tiers:
- **Free:** 50 questions/month, basic features
- **Premium:** $19/month - Unlimited questions, analytics
- **Enterprise:** Custom pricing - Institution features

### What subjects does EDIFY cover?

Currently focused on:
- **Computer Science:** Programming, algorithms, data structures
- **AI/Machine Learning:** Neural networks, deep learning, NLP
- **Mathematics:** Calculus, linear algebra, statistics
- **Data Science:** Python, R, data analysis, visualization

More subjects coming in Q1 2026 (see [Roadmap](#roadmap))

---

## Technical Questions

### What AI model does EDIFY use?

EDIFY uses **Azure OpenAI GPT-4** with a custom RAG (Retrieval-Augmented Generation) layer that combines:
- Vector similarity search for semantic understanding
- BM25 keyword search for precision
- Learner-aware reranking for personalization

### How does the RAG system work?

**Simplified flow:**
1. You ask a question
2. EDIFY searches 10,000+ educational documents
3. Top 20 relevant chunks retrieved (hybrid vector + keyword search)
4. Re-ranked based on your skill level and learning history
5. Top 5 chunks sent to GPT-4 as context
6. Personalized response generated with citations
7. Response cached for faster future access

See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details.

### Why are responses so fast (<2 seconds)?

**Speed optimizations:**
- Multi-tier caching (in-memory + Redis)
- Parallel processing of retrieval and generation
- Optimized embedding models (384-dim vs 1536-dim)
- Edge computing for global users

### What data does EDIFY use for responses?

- **Curated educational content:** Textbooks, papers, courses (licensed)
- **Public knowledge:** Wikipedia, arXiv, open educational resources
- **Custom uploads:** Content added by educators (if applicable)

All sources are cited in responses.

### Can I use EDIFY offline?

No, EDIFY requires internet connection for:
- Access to AI models (Azure OpenAI)
- Real-time content retrieval
- Progress syncing

**Coming soon:** Offline mode with limited functionality (cached content only)

---

## Learning & Usage

### How do I get the best results from EDIFY?

**Best practices:**
1. **Be specific:** "Explain gradient descent with examples" vs "machine learning"
2. **Set your skill level:** Update profile so responses match your knowledge
3. **Ask follow-up questions:** Build on previous responses
4. **Use learning goals:** Define what you want to achieve
5. **Review citations:** Explore source materials

See [USER_GUIDE.md](USER_GUIDE.md) for detailed tips.

### Can EDIFY help with homework or assignments?

**Yes, ethically:**
- ✅ Explaining concepts you don't understand
- ✅ Providing examples similar to your assignment
- ✅ Helping debug code errors
- ✅ Suggesting learning resources

**Not for:**
- ❌ Directly solving assignments
- ❌ Writing essays verbatim
- ❌ Completing exams

**Remember:** EDIFY is a tutor, not a shortcut. Use it to *learn*, not just to *complete tasks*.

### How accurate are EDIFY's responses?

- **Citation accuracy:** 98.5% (validated against ground truth)
- **Factual accuracy:** >95% (based on user feedback)
- **Error handling:** Clearly states when uncertain

**Always verify critical information** using provided citations.

### What languages does EDIFY support?

**Currently:** English only

**Coming Q1 2026:**
- Spanish
- French
- Mandarin Chinese

### How does EDIFY track my progress?

**Metrics tracked:**
- Concepts mastered (based on questions and understanding depth)
- Learning velocity (concepts per week)
- Retention rate (periodic review performance)
- Engagement score (session quality, follow-up depth)

**You control your data:** View, download, or delete anytime in Settings.

---

## Pricing & Subscriptions

### How much does EDIFY cost?

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0/month | 50 questions/month, basic features |
| **Premium** | $19/month | Unlimited questions, analytics, priority support |
| **Enterprise** | Custom | Institution features, dedicated support, white-label |

**Student discount:** 50% off Premium with valid .edu email

### Can I try Premium before paying?

Yes! **7-day free trial** available:
1. Go to Settings > Subscription
2. Click "Start Premium Trial"
3. No credit card required
4. Cancel anytime during trial

### How do I cancel my subscription?

1. Settings > Subscription > Manage
2. Click "Cancel Subscription"
3. Confirm cancellation
4. Access continues until period end
5. Data retained for 90 days

**No cancellation fees.**

### What payment methods are accepted?

- Credit/debit cards (Visa, Mastercard, Amex)
- PayPal
- Bank transfer (Enterprise only)

**Secure payments via Stripe** (PCI-DSS compliant)

### Is there a refund policy?

**7-day money-back guarantee:**
- Full refund if canceled within 7 days of purchase
- No questions asked
- Processed within 5-7 business days

**After 7 days:**
- No refunds, but you can cancel anytime
- Access continues until end of billing period

---

## Privacy & Security

### Is my data secure?

**Yes.** EDIFY implements enterprise-grade security:
- **Encryption:** AES-256 at rest, TLS 1.3 in transit
- **Authentication:** OAuth 2.0 + JWT tokens
- **Compliance:** GDPR, SOC 2, FERPA (for educational institutions)
- **Monitoring:** 24/7 security monitoring and alerts

### What data does EDIFY collect?

**Account data:**
- Name, email, password (hashed)
- Learning profile (subjects, goals, skill levels)

**Usage data:**
- Questions asked
- Topics explored
- Progress metrics
- Session analytics

**NOT collected:**
- Browsing history outside EDIFY
- Keystrokes or screenshots
- Sensitive personal information (SSN, financial data)

See [Privacy Policy](https://edify.ai/privacy) for full details.

### Can EDIFY staff see my questions?

**General policy:**
- Questions are anonymized for aggregate analytics
- Individual questions not reviewed unless:
  - You report a problem
  - Automated abuse detection triggers
  - Legal requirement

**Your control:**
- Opt out of analytics: Settings > Privacy
- Delete conversation history anytime

### Is EDIFY GDPR compliant?

**Yes.** EDIFY complies with GDPR:
- **Right to access:** Download all your data
- **Right to deletion:** Delete account and all data
- **Right to portability:** Export data in JSON format
- **Right to object:** Opt out of analytics

**Data retention:** 90 days after account deletion

### Can I use EDIFY at my school/university?

**Yes.** EDIFY is designed for educational institutions:
- FERPA compliant for student data
- SSO integration available (Enterprise)
- Admin controls for educators
- Class management features

Contact enterprise@edify.ai for institutional pricing.

---

## For Educators

### How do I get educator access?

1. Sign up with institutional email (.edu)
2. Go to Settings > Account Type
3. Click "Request Educator Access"
4. Provide verification:
   - School name
   - Department
   - Course taught
5. Approval within 24-48 hours

### Can I upload my own course materials?

**Yes (Premium/Enterprise):**
- Upload PDFs, DOCX, TXT files
- Content becomes searchable for your students
- Retains ownership of materials
- Can make private (your students only) or public

**Supported formats:**
- Documents: PDF, DOCX, TXT, Markdown
- Presentations: PPTX (converted to text)
- Code: Python, Java, C++, JavaScript (preserved formatting)

### How do I track student progress?

**Educator Dashboard** shows:
- Individual student analytics
- Class-wide metrics (average progress, engagement)
- Common difficulties (topics where students struggle)
- Popular topics
- Time-to-mastery averages

**Export reports:**
- PDF summaries
- CSV data for custom analysis
- Individual progress reports

### Can I integrate EDIFY with my LMS?

**Coming Q1 2026:** LMS integrations
- Canvas
- Blackboard
- Moodle

**Currently:** Use EDIFY standalone
- Share links to specific topics
- Export progress reports manually

---

## Troubleshooting

### Why are responses slow?

**Common causes:**
1. **First time query:** No cache yet (subsequent = faster)
2. **Complex question:** Requires more processing
3. **Peak usage:** High server load

**Solutions:**
- Break complex questions into parts
- Check internet connection speed
- Try during off-peak hours

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed diagnostics.

### Why am I getting "No relevant content found"?

**Possible reasons:**
1. **Very niche topic:** Not enough content indexed
2. **Typo in question:** Check spelling
3. **Subject not covered:** EDIFY focuses on CS/AI/Math

**Solutions:**
- Rephrase question with broader terms
- Check available subjects
- Upload custom content (if educator)

### My account is locked. What do I do?

**Common causes:**
- Too many failed login attempts (security lockout)
- Payment issue (Premium/Enterprise)
- Terms of service violation

**Solution:**
1. Wait 30 minutes (auto-unlock for failed logins)
2. Check email for payment notifications
3. Contact support@edify.ai if still locked

### How do I reset my password?

1. Go to login page
2. Click "Forgot Password"
3. Enter your email
4. Check inbox for reset link (check spam)
5. Follow link to set new password
6. Link expires in 1 hour

**Still not working?** Email support@edify.ai

### Why can't I access Premium features?

**Check:**
1. Subscription status: Settings > Subscription
2. Payment method valid: Update if expired
3. Trial period ended: Upgrade to paid

**Common issue:** Payment failure
- Update payment method
- Wait 5 minutes for system refresh

---

## Roadmap

### What's coming next?

**Q1 2026:**
- Multi-language support (Spanish, French, Mandarin)
- LMS integrations (Canvas, Blackboard, Moodle)
- Mobile apps (iOS, Android)
- Enhanced accessibility (WCAG 2.1 AA)

**Q2 2026:**
- Advanced analytics dashboard
- Custom curriculum builder
- White-label solution
- Collaborative learning features

**Q3 2026:**
- AI teaching assistants for educators
- Gamification and achievements
- Real-time study groups
- AR/VR learning experiences

See [STATUS.md](../STATUS.md) for detailed roadmap.

---

## Still Have Questions?

**Documentation:**
- [User Guide](USER_GUIDE.md) - Complete platform guide
- [API Documentation](API.md) - For developers
- [Troubleshooting](TROUBLESHOOTING.md) - Fix common issues

**Community:**
- [GitHub Discussions](https://github.com/THEDIFY/THEDIFY/discussions) - Ask the community
- [Stack Overflow](https://stackoverflow.com/questions/tagged/edify) - Technical questions

**Support:**
- **Email:** support@edify.ai
- **Response time:** 24h (Premium), 48h (Free)
- **Phone:** Enterprise tier only

---

*FAQ Version: 1.2.0 | Last Updated: December 17, 2025*

**Can't find your question? Ask in our [community forum](https://github.com/THEDIFY/THEDIFY/discussions) or email support@edify.ai**
