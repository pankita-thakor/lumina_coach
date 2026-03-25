class SituationTemplate {
  const SituationTemplate({required this.title, required this.body});

  final String title;
  final String body;
}

/// Curated prompts — tap to open Coach with pre-filled draft.
const situationTemplates = <SituationTemplate>[
  SituationTemplate(
    title: 'Decline extra scope politely',
    body:
        'Thanks for thinking of me for this. I don\'t have bandwidth to take on the new scope this sprint without dropping quality on X. Could we narrow the ask or push the due date?',
  ),
  SituationTemplate(
    title: 'Request deadline extension',
    body:
        'I want to deliver this properly. With the new dependency, the current due date is tight. Could we move it to Friday so I can include proper testing?',
  ),
  SituationTemplate(
    title: 'Push back on unrealistic timeline',
    body:
        'I\'m aligned on the outcome. To hit that date I\'d need either reduced scope or an extra resource on backend. Which path do you prefer?',
  ),
  SituationTemplate(
    title: 'Salary negotiation opener',
    body:
        'I\'d like to discuss compensation. Based on the impact of the last two launches and market data, I\'m targeting a revision to my base salary. When is a good time this week?',
  ),
  SituationTemplate(
    title: 'Follow up after no response',
    body:
        'Hi — bumping this in case it got buried. I need your input on the budget line by Thursday to finalize the proposal. Can you confirm today?',
  ),
  SituationTemplate(
    title: 'Give constructive peer feedback',
    body:
        'In yesterday\'s review, when the discussion heated up, I noticed interruptions cut off quieter voices. I think we\'ll get better decisions if we slow down and hear everyone out.',
  ),
  SituationTemplate(
    title: 'Apologize with accountability',
    body:
        'I missed the commitment on the design handoff and that blocked you — that\'s on me. I\'ve adjusted my process so drafts land 24h earlier. Here\'s the file now.',
  ),
  SituationTemplate(
    title: 'Set boundary with manager',
    body:
        'I\'m glad to help, but recurring Friday evening pings are hard to sustain. Can we batch non-urgent items to Monday mornings unless it\'s truly an incident?',
  ),
  SituationTemplate(
    title: 'Customer complaint — de-escalation',
    body:
        'I\'m sorry this fell short of what you expected. Here\'s what happened and the fix we\'ve shipped. I\'d like to offer X as a next step — does that work for you?',
  ),
  SituationTemplate(
    title: 'Say no to a meeting',
    body:
        'I may not need to be in this sync — the decision is on API contracts and that\'s Anna\'s lane. Happy to review notes async unless you need me live.',
  ),
  SituationTemplate(
    title: 'Negotiate scope with stakeholder',
    body:
        'We can deliver A+B by the date, or A+B+C if we add two days for QA. Which tradeoff matches your launch priority?',
  ),
  SituationTemplate(
    title: 'Ask for clarity',
    body:
        'I want to make sure I implement the right thing. Can you confirm whether the KPI is activation rate or paid conversion for this experiment?',
  ),
  SituationTemplate(
    title: 'Sensitive peer nudge',
    body:
        'Hey — I might be misreading this, but the tone in the thread felt sharper than usual. Want to hop on a quick call so we sync without misunderstandings?',
  ),
  SituationTemplate(
    title: 'Family boundary',
    body:
        'I love seeing everyone, but back-to-back weekend trips are draining me. I\'m going to sit this one out and catch the next gathering.',
  ),
  SituationTemplate(
    title: 'Partner check-in',
    body:
        'I\'ve been stressed and I think I\'ve been short-tempered. That\'s not about you. Can we carve 30 minutes tonight to decompress together?',
  ),
  SituationTemplate(
    title: 'Landlord / service issue',
    body:
        'The heating issue is still unresolved after the visit on Monday. Please send a technician by Wednesday or I\'ll need to escalate per the lease terms.',
  ),
  SituationTemplate(
    title: 'Cold outreach — concise',
    body:
        'I help mobile teams cut payment drop-off. I recently moved a fintech from 62%→78% completion in 6 weeks. Worth a 15-min chat?',
  ),
  SituationTemplate(
    title: 'Interview thank-you',
    body:
        'Thanks for today — especially the discussion on monetization tradeoffs. I\'m even more excited about the role. Happy to dive deeper on the growth experiments I mentioned.',
  ),
  SituationTemplate(
    title: 'Decline introduction',
    body:
        'I appreciate the intro. I\'m heads-down on our release until month-end, so I\'m pausing new intros. Mind reconnecting in April?',
  ),
  SituationTemplate(
    title: 'Project delay announcement',
    body:
        'We discovered a regression in checkout that needs a fix before we ship. New GA is March 28. I\'ll post a daily note in #releases until we\'re green.',
  ),
  SituationTemplate(
    title: 'Peer code review — firm but kind',
    body:
        'Nice direction on the cache layer. I\'m concerned about race conditions when two writers hit the same key — could we add a mutex or move to single-writer queues?',
  ),
  SituationTemplate(
    title: 'React to public criticism',
    body:
        'Thanks for the candid feedback. We should have communicated the pricing change earlier. We\'re rolling back grandfathering for annual plans and posting a clearer timeline today.',
  ),
  SituationTemplate(
    title: 'Ask mentor for advice',
    body:
        'I\'m weighing IC vs EM paths. I enjoy technical depth but I also like developing people. Could I buy you coffee and hear how you chose at my level?',
  ),
  SituationTemplate(
    title: 'Decline volunteer ask',
    body:
        'I care about this initiative, but I can\'t commit reliably this quarter. I can donate X or help draft the newsletter once — would either help?',
  ),
  SituationTemplate(
    title: 'Informal networking',
    body:
        'I\'m exploring roles where I can own retention for consumer subscriptions. If you hear of teams solving churn with experimentation culture, I\'d love an intro.',
  ),
  SituationTemplate(
    title: 'Escalate politely',
    body:
        'We\'ve been waiting on the security review for 10 days and launch is blocked. Can you either assign a reviewer today or confirm we should proceed with documented risk acceptance?',
  ),
  SituationTemplate(
    title: 'Close a loop',
    body:
        'Looping back with the numbers we discussed: variance is +3.2% WoW, driven by onboarding. Next step is the experiment doc I linked — feedback by EOD tomorrow?',
  ),
  SituationTemplate(
    title: 'Remote etiquette',
    body:
        'I noticed we\'re stacking 6 hours of calls on Tuesdays. Could we move the design critique async (Loom) so makers get focus blocks?',
  ),
  SituationTemplate(
    title: 'Ask for raise after win',
    body:
        'The renewal campaign beat target by 18%. Given the ownership I took end-to-end, I\'d like to revisit my compensation to reflect that impact.',
  ),
  SituationTemplate(
    title: 'End a recurring meeting',
    body:
        'This weekly sync often ends early. I\'d suggest we move to biweekly and use a Slack thread for status unless there\'s a blocker. Does that work?',
  ),
  SituationTemplate(
    title: 'Clarify role friction',
    body:
        'I want us to succeed, but the overlapping PM/EM decisions on priorities slowed us last sprint. Could we document a simple RACI so handoffs are crisp?',
  ),
  SituationTemplate(
    title: 'Difficult news to team',
    body:
        'Leadership decided to pause the beta geo expansion. I know this is disappointing. We\'re redirecting effort to reliability wins that unblock growth next half — I\'ll share the roadmap Friday.',
  ),
];
