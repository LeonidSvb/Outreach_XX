# Reply Patterns Analysis — AI Auto-Reply Agent Setup

**Based on:** 145 real lead replies, 96 unique threads, Jan–Mar 2026  
**Positioning:** Connector (not vendor). You surface connections. Market rotates around you.

---

## Part 1 — Good Patterns: What Worked

### Pattern 1A — "Simple Yes, Straight to Schedule"

**What happened:** Lead sent a short positive reply. We responded with next step. Meeting booked.

**Real examples:**
- ariel@absstaffingsolutions.com: "yes please" → meeting completed
- dfox@focusgts.com: "Sure" → meeting
- daniel@noaccentcallers.com: "Let's do it" → meeting
- mfrieling@localworldinc.com: "Sure, happy to help" → "Thursday at 1:30 PM ET works. Send an invite."
- cindie@theallstaragency.net: "Sure. Would love the intros." → meeting

**Why it worked:** Zero friction. They said yes, we moved immediately to scheduling.

**AI Template — Category: Simple Yes**
```
[Calendly link]

Pick a time this week — will walk you through the names.
```
No pleasantries. No re-explaining. Just the link and one line.

---

### Pattern 1B — "One Question, Then Yes"

**What happened:** Lead asked one clarification, we answered, they booked.

**Real examples:**
- barry@dentalcareerservices.com: "I'm not sure what this is regarding?" → we explained → "I would be open to a conversation" → "pick a day and time and I will make it work"
- bart@craftwrx.com: "What is it that your company does?" → we explained → "Wow, that's wild. Regardless, I am interested in what you guys are doing."
- oyinc@upscalems.com: "Yes. What is your process?" → we explained → "Okay. Let's try it out"
- kelly.oneil@kastelstaffing.com: asked about construction type/location → we answered → gave Calendly
- nanthini@newtalents.ca: "I need some more information" → we explained → "Yes, I'm fine with it"

**Why it worked:** They were already warm, just needed one signal that this was real and relevant. Our response triggered the yes.

**AI Template — Category: "Tell me more / What do you do?"**
```
Simple setup.

I'm sitting on names in [their sector] — companies that need what you do. 
I make the intro, you take the call. If it lands, we talk next steps.

Worth 15 minutes to look at the names?

[Calendly link]
```
Key: specific to their sector, no explaining a "service", just "I have names".

---

### Pattern 1C — "Curious → Warmed Up → Scheduled"

**Real examples:**
- sloane@engin.co: "Sure who do you know?" → we replied → "Sure. Monday? We need staffing warm leads but also work with high volume employers." → "monday at 10am est"
- josed@vantech.com.co: "Ok im interested. Are you offering leads? If so, what would you like in exchange?" → we explained → "Yes i will take the meeting please, how is your monday afternoon around 3pm?"
- sstamand@proforce.ca: "Hey Oan, sure I'm curious. What's the next step?" → meeting completed

**Why it worked:** Lead already had intent. We just needed to answer their specific question and move to a time.

**AI Template — Category: Curious / "What's the next step?"**
```
Next step is a quick call — I'll pull up the names on my end, 
you tell me if they're relevant.

No commitment beyond that.

[Calendly link]
```

---

## Part 2 — Bad Patterns: What Killed the Conversation

> Note: our outbound replies have empty body_text in DB. Bad replies below are reconstructed from lead's NEXT message - their reaction is the evidence.

### Pattern 2A — Over-Explaining Killed the Vibe

**Thread: m@searchwithjack.com**
- Lead: "Could you send more info, thanks"
- Lead (after our reply): "Thanks for the context, Aria! I'll pass, thanks." then "Unsubscribe please"

What our reply probably looked like:
> "Hi M, thanks for your interest! We're a B2B connector company that helps staffing agencies
> find new clients through our targeted outreach approach. Here's how it works: we identify
> relevant hiring signals in your sector, map the right decision makers, and run targeted
> sequences to start conversations on your behalf. Our process typically involves..."

Why it failed: "our process" + step-by-step explanation = vendor pitch mode.
Connector frame collapses the moment you start explaining a service structure.

Better reply:
> I monitor this sector and surface connections when timing lines up on both sides.
>
> Worth a 15-min call to see if what I'm seeing is relevant for you?
> https://cal.com/leonidshvorob/fit-check-call

---

**Thread: slabat@dssstaffing.com**
- Lead: "I looked at your website this morning and it didn't come up. Can you tell me what your company does."
- Lead (after our reply): "Not interested. thanks"

What our reply probably looked like:
> "Hi Scott! The domain I reach out from is separate from our main website, my apologies
> for the confusion. We help staffing companies connect with companies that are actively
> hiring. Our platform identifies hiring intent signals and routes introductions..."

Why it failed: defensive about the website AND switched into vendor pitch in the same reply.
Two problems, neither solved.

Better reply:
> Good catch - the sending domain isn't the main one, my mistake.
>
> I monitor the staffing sector and surface connections when timing is there.
> Worth a quick call?
> https://cal.com/leonidshvorob/fit-check-call

---

**Thread: markherman@sympl.be**
- Lead: "i literally have no idea what you mean with that... I am afraid your AI mailing tool needs finetuning"
- Lead (after 2 of our replies): "no need at this stage, tx"

Why it failed: they called it an AI tool after seeing our REPLY - meaning our reply felt templated/automated.
Two more replies made it worse. The hole gets deeper the more you explain.

Better reply (one shot):
> Real person - sympl came up on my radar in this sector, that's why I sent the note.
>
> I monitor who's looking for what you do and surface the timing.
> 15 min if curious. https://cal.com/leonidshvorob/fit-check-call

Rule: If they're confused, simplify once and move to a call. Never explain twice.

---

### Pattern 2B — Credibility Check Not Handled Right

**Thread: jvines@pursuitsalessolutions.com**
- Lead (first): "Sure, feel free to put me on an intro email with them." [positive start]
- Lead (after our reply): "Can you share what an engagement looks like? And also, do you have active relationships with these VPs?"
- Result: 4 of our replies, still ended NOT_INTERESTED

Why it failed: they asked one sharp question, we took 4 rounds to answer it.
More rounds = less confidence. A connector answers in one line and moves to the call.
Also: "do you have active relationships" is a credibility test, not an info request.
Trying to prove it by explaining = failed the test.

Better reply:
> I monitor this sector and have access to the right people when their timing is there.
>
> The call is where I'd pull up what's specific to your pipeline - easier to show than explain.
> https://cal.com/leonidshvorob/fit-check-call

Rule: Never prove. Redirect. The call is the proof.

---

**Thread: matt.ellis@engagepartners.co.uk**
- Lead (first): "Tell me more Leo..." [warm]
- Lead (second): "In what professional capacity do you interact with senior leadership in a school? Can you send me your LinkedIn profile please? Do you act on behalf of any education recruitment agencies right now?"
- Result: thread went cold

This was a professional credibility audit. Three questions at once = high intent but high skepticism.
We probably either answered too vaguely (lost credibility) or too much (sounded defensive).

Better reply:
> I'm independent - not representing any agencies, just monitoring the education sector
> for timing signals.
>
> LinkedIn: [link]. Easier to walk you through the specifics on a call.
> https://cal.com/leonidshvorob/fit-check-call

Key: answer the LinkedIn ask directly (it's a legitimacy check, not optional), keep rest short.

---

### Pattern 2C — Performance Objection Handled Wrong

**Thread: mae@executivehunt.com**
- Lead (first): "I don't understand what you are offering? Do you know companies that need recruitment services?"
- Lead (second): "we would only pay once we have been paid from the client - happy to pay from the placement, however we would never pay something upfront"
- Lead (third): "Is this automated? I haven't been anywhere"

Three rounds ending in "is this automated" = they gave up and assumed it was a bot.
Our first reply didn't land (too vendor), then we hit pricing, then they disengaged.

Better sequence:

Reply 1 to "I don't understand":
> I monitor this sector and have access to companies looking for recruitment partners right now.
> When timing lines up - I surface the intro.
>
> Worth a call to see if what I'm looking at is relevant for you?
> https://cal.com/leonidshvorob/fit-check-call

If they then raised the upfront objection (reply 2 only if needed):
> Got it - I don't run this purely on success fee, but the entry point is small
> and we figure out structure together after that.
>
> Call first though - need to see if the fit is even there.
> https://cal.com/leonidshvorob/fit-check-call

---

**Thread: darren@spotwork.co**
- Lead (first): "Close me a deal and I'll reward you handsomely"
- Lead (after our reply): "Nothing upfront. I've tried this many times before and it never works in my industry."

His first message was actually a yes with conditions - "close me a deal first."
Our reply probably explained the pricing model in detail, which triggered the resistance.
You can't win a pricing conversation by email.

Better reply to "close me a deal":
> I hear that - happy to walk you through the structure on a quick call.
> The entry point is small, and after that we figure out what makes sense for both sides.
> https://cal.com/leonidshvorob/fit-check-call

Rule: Any pricing question = move to call immediately. Never negotiate by email.

---

### Pattern 2D — Follow-Up After "No" (Reputation Risk)

**What happened:** Lead said no, sequence continued, they wrote back angry.

**Real examples:**
- anneli@boulevardrecruiting.com: "No thanks" → follow-up → "I already said no thanks"
- mattias@vetgig.se: "No thanks" → follow-up → "Please stop email me! I have said no thanks already!"
- adam@mynewtalent.com: "Stop it. This is being reported as harassment"
- heather@offshorelaunch.com: "Unsubscribe" → "I unsubscribed."
- rick@rushandcompany.com: "Remove unsubscribe cancel" → "See previous email."

**This is not an AI reply issue — it's a sequence stop issue.**  
Any "no/remove/unsubscribe/stop" reply must trigger immediate stop + blocklist. AI agent action: reply once with a graceful exit, then add to blocklist. No further sends.

**AI Template — Category: Unsubscribe / Hard No**
```
Got it. Won't reach out again.
```
One line. Nothing more. Then blocklist.

---

## Part 3 — Objection Handling

### Objection 1 — "I Won't Pay Upfront" (Most Common)

**Exact quotes from leads:**
- jolie@paradigmstaffing.com: *"Is this a pay in advance system or is it commission based? If I pay after I land the client, I'd be open to learning more, but if it's in advance, I'll pass at this time."*
- darren@spotwork.co: *"Nothing upfront. I've tried this many times before and it never works in my industry."*
- mae@executivehunt.com: *"we would only pay once we have been paid from the client — happy to pay from the placement like a referral scheme, however we would never pay for something upfront"*
- ryan@commissioncrowd.com: *"Just make the introduction by email and we'll pay you a 15% commission after they become a paying client."*

**What they're really saying:** "I've been burned before by people who promised intros and delivered nothing. I won't risk money on vapor."

**Your positioning opportunity:** Small entry-point retainer (2–3 intros worth) = skin in the game from both sides. Not "upfront for a service" — it's a qualifier that makes both sides commit. After first 2–3 intros, pure success fee.

**AI Template — Category: "Won't Pay Upfront"**
```
Got it - I don't run this purely on success fee,
but the entry point is small and the structure is flexible after that.

Worth a call to see if the fit is even there first.
https://cal.com/leonidshvorob/fit-check-call
```

**If they push back again:**
```
Makes sense - happy to walk you through how it works on a call.
It's not a rigid structure, we figure out what works for both sides.
https://cal.com/leonidshvorob/fit-check-call
```

Rule: Never commit to a specific structure by email. "We figure it out together" = flexible AND moves to call.

---

### Objection 2 — "What Exactly Are You Offering?" / Confusion

**Exact quotes:**
- igor@skillers.tech: *"What exactly are you offering?"*
- bart@craftwrx.com: *"What is it that your company does? Are you developers?"*
- jjames@flextechnow.com: *"if you're talking about a pipeline of candidates, yes... if you're talking about customers needing people, I am covered"*
- sb@navigator.lg.ua: *"I didn't understand anything. Do you need employees from Ukraine? What positions are available?"*
- barry@dentalcareerservices.com: *"I'm not sure what this is regarding?"*

**Root cause:** The cold email was too vague or the ICP/pain line didn't connect clearly. The connector frame sometimes reads ambiguously.

**AI Template — Category: "I don't understand what you're offering"**
```
Simple version -

I monitor this sector and have access to companies looking for what you do
when their timing is there. I surface the connection, you take it from there.

Worth 15 minutes to see if it lines up?
https://cal.com/leonidshvorob/fit-check-call
```

Key: no name-dropping, no system/platform language. "I monitor this sector, I have access" = connector.
Details of how you find them = for the call only.

---

### Objection 3 — "I Don't Jump on Calls Before I Know What You're Offering"

**Exact quotes:**
- klaus.preschle@talmore.co: *"I do not jump on calls before I know what the other party basically offers: sales pitch? website?"*
- matthias@linguedo.com: *"That's very vague — please let me know to whom you're connected and how good the connection is"*
- geremy@placedrecruitment.com.au: *"Do we know each other?"*

**What they want:** Written summary + credibility signal before investing 30 min.

**AI Template — Category: "Send me info first / no calls without context"**
```
Fair.

I monitor the [staffing/recruiting] sector and have access to companies
when their timing is there. When it lines up with what you do - I surface it.

Small entry point to start, then we figure out structure together.

If that lands - worth a call to see what I'm specifically looking at for you.
https://cal.com/leonidshvorob/fit-check-call
```

Note: no name-dropping, no "company names by email." Give them the concept, not the goods.
The goods are for the call.

---

### Objection 4 — Wrong Person / Wrong Vertical

**Exact quotes:**
- ranisef@proforce.ca: *"I have nothing to do with line workers, sorry"*
- dlyth@clmsearch.com: *"I don't even work in this industry"*
- paul@fcpartners.co.uk: *"Think you've got the wrong full circle partners"*

**AI Template — Category: Wrong Person**
```
My mistake — wrong read on the signal.

Appreciate you letting me know.
```
Done. Don't try to recover. Mark as wrong ICP in your system.

---

### Objection 5 — "We Only Pay From Placement / Success-Fee Only"

Different from "won't pay upfront" — these leads are actually agreeing with your model conceptually but signaling they want pure success fee.

**Example:**
- ryan@commissioncrowd.com: *"Just make the introduction by email and we'll pay you a 15% commission after they become a paying client of ours."*

This person is describing exactly a performance model but wants zero upfront. They're still a lead. 

**AI Template:**
```
Works for me.

Let me know what a "paying client" looks like on your end 
so we're aligned on the trigger point.

And the intro — want me to make it by email, or would a 
quick 3-way call work better?
```

---

## Part 4 — Complete AI Agent Configuration

### Rule Structure

| Label | Trigger | Response Type | Template |
|-------|---------|---------------|----------|
| INTERESTED (simple yes) | "yes", "sure", "let's do it", "ok" | Reply immediately | Template 1A — Send Calendly |
| INTERESTED (questions) | "tell me more", "what is your process", "what are you offering" | Reply immediately | Template 1B — Short explanation + Calendly |
| INTERESTED (credibility check) | "do you have real relationships", "send your LinkedIn", "who are you" | Reply immediately | Template 2B — Confidence, not proof |
| NOT_INTERESTED (upfront objection) | "not upfront", "success only", "commission after placement" | Reply immediately | Objection 1 template |
| NOT_INTERESTED (hard no) | "no", "remove", "stop", "unsubscribe" | One-line exit | Template 2D — blocklist |
| NEITRAL | "do we know each other", "what exactly are you offering" | Reply immediately | Objection 2 template |

---

### Prompt for AI Agent (Connector Frame)

Use this as the base system prompt when configuring the AI Reply Agent in PlusVibe:

```
You are Leo — a connector in the staffing and recruitment industry.
You are not a vendor. You are not selling a service.
You monitor hiring signals across industries and route introductions 
between recruitment agencies and companies that need their services.

Your voice:
- Short sentences. Second-grade words.
- Never explain more than 2 sentences.
- Never say "our platform", "our service", "our process".
- Always sound like you're busy and selective.
- Never beg, justify, or over-explain.
- Never use exclamation points.

When someone asks "what do you do":
Say you surface connections between [their vertical] and companies 
that are actively looking for what they offer. 
Offer a 15-minute call or drop 2–3 names in writing.

When someone says no / remove / unsubscribe:
Respond with one line: "Got it. Won't reach out again."
Then stop all follow-ups.

When someone raises the upfront payment issue:
Explain: small entry point covers 2–3 intros, after that pure success fee.
Both sides have skin in the game. Offer a call to look at the names first.

When someone asks if you're automated:
Reference their company name specifically. 
Do not say "I'm a real person" — show it through specificity.

Goal of every reply: move to a 15-minute call or get a written yes to see names.
Never close on a long meeting or a pitch. Just "look at the names."

Offer Calendly link at the end of every positive/neutral reply.
Calendly: [INSERT YOUR LINK]
```

---

## Part 5 — Quality Issues to Fix in Cold Emails (Not AI Agent)

These came from leads, not from AI agent failures. Fix in the cold email templates:

1. **Capital letters at sentence start** — at least 5 complaints. Some UK leads were particularly upset.
2. **No website findable** — george@dgctoday.com, slabat@dssstaffing.com couldn't find the website from the sending domain. Either add website to signature or use the same domain for website.
3. **No detail in offer** — "there is no detail or context in your offer" (sireton@ricesp.com). The cold emails need to be more specific about the ICP you're connecting them with.
4. **Vague intro line** — "I'm in the middle of X and Y" needs the X to be very specific to their vertical or it reads as spam.
