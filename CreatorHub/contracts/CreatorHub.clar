;; CreatorHub - Decentralized Content Creator Platform
;; A blockchain-based platform for content creation, fan engagement,
;; and monetization with community-driven rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-tokens (err u105))

;; Token constants
(define-constant token-name "CreatorHub Creator Token")
(define-constant token-symbol "CHT")
(define-constant token-decimals u6)
(define-constant token-max-supply u200000000000) ;; 200k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-post u2000000) ;; 2 CHT
(define-constant reward-like u500000) ;; 0.5 CHT
(define-constant reward-collaboration u15000000) ;; 15 CHT
(define-constant reward-milestone u25000000) ;; 25 CHT
(define-constant reward-subscription u8000000) ;; 8 CHT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-post-id uint u1)
(define-data-var next-collab-id uint u1)
(define-data-var next-event-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Creator profiles
(define-map creator-profiles
  principal
  {
    username: (string-ascii 32),
    creator-type: (string-ascii 16), ;; "artist", "writer", "musician", "developer", "designer"
    total-posts: uint,
    total-likes: uint,
    followers: uint,
    collaborations: uint,
    creator-level: uint, ;; 1-10
    reputation-score: uint,
    join-date: uint,
    last-activity: uint
  }
)

;; Content categories
(define-map content-categories
  (string-ascii 24)
  {
    category-type: (string-ascii 16), ;; "art", "music", "writing", "video", "code"
    base-points: uint,
    engagement-multiplier: uint, ;; 1-3
    active: bool
  }
)

;; Content posts
(define-map content-posts
  uint
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-ascii 256),
    content-type: (string-ascii 24),
    content-url: (string-ascii 128),
    likes: uint,
    shares: uint,
    post-date: uint,
    monetized: bool,
    verified: bool
  }
)

;; Post interactions
(define-map post-interactions
  { post-id: uint, user: principal }
  {
    interaction-type: (string-ascii 8), ;; "like", "share", "comment"
    interaction-date: uint,
    tip-amount: uint
  }
)

;; Collaboration projects
(define-map collaboration-projects
  uint
  {
    initiator: principal,
    project-title: (string-ascii 64),
    project-description: (string-ascii 200),
    project-type: (string-ascii 16), ;; "music", "art", "writing", "tech", "mixed"
    max-collaborators: uint,
    current-collaborators: uint,
    duration-days: uint,
    start-date: uint,
    end-date: uint,
    reward-pool: uint,
    active: bool
  }
)

;; Collaboration participation
(define-map collaboration-participation
  { collab-id: uint, collaborator: principal }
  {
    join-date: uint,
    contribution-score: uint,
    role: (string-ascii 16),
    completed: bool
  }
)

;; Creator events
(define-map creator-events
  uint
  {
    host: principal,
    event-title: (string-ascii 64),
    event-type: (string-ascii 16), ;; "showcase", "workshop", "meetup", "launch"
    event-description: (string-ascii 200),
    max-attendees: uint,
    current-attendees: uint,
    event-date: uint,
    ticket-price: uint,
    active: bool
  }
)

;; Event attendance
(define-map event-attendance
  { event-id: uint, attendee: principal }
  {
    registration-date: uint,
    attended: bool,
    feedback-score: uint
  }
)

;; Subscription tiers
(define-map subscription-tiers
  { creator: principal, tier-name: (string-ascii 16) }
  {
    tier-description: (string-ascii 128),
    monthly-price: uint,
    benefits: (string-ascii 200),
    subscriber-count: uint,
    active: bool
  }
)

;; Creator milestones
(define-map creator-milestones
  { creator: principal, milestone: (string-ascii 32) }
  {
    achievement-date: uint,
    milestone-value: uint,
    reward-earned: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (creator principal))
  (match (map-get? creator-profiles creator)
    profile profile
    {
      username: "",
      creator-type: "artist",
      total-posts: u0,
      total-likes: u0,
      followers: u0,
      collaborations: u0,
      creator-level: u1,
      reputation-score: u100,
      join-date: stacks-block-height,
      last-activity: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Initialize content categories
(define-public (init-content-categories)
  (begin
    (map-set content-categories "digital-art" {category-type: "art", base-points: u20, engagement-multiplier: u2, active: true})
    (map-set content-categories "music-track" {category-type: "music", base-points: u25, engagement-multiplier: u3, active: true})
    (map-set content-categories "blog-post" {category-type: "writing", base-points: u15, engagement-multiplier: u2, active: true})
    (map-set content-categories "video-content" {category-type: "video", base-points: u30, engagement-multiplier: u3, active: true})
    (map-set content-categories "code-project" {category-type: "code", base-points: u22, engagement-multiplier: u2, active: true})
    (map-set content-categories "photography" {category-type: "art", base-points: u18, engagement-multiplier: u2, active: true})
    (print {action: "content-categories-initialized"})
    (ok true)
  )
)

;; Create content post
(define-public (create-post (title (string-ascii 64)) (description (string-ascii 256)) (content-type (string-ascii 24)) (content-url (string-ascii 128)))
  (let (
    (post-id (var-get next-post-id))
    (category (unwrap! (map-get? content-categories content-type) err-not-found))
    (profile (get-or-create-profile tx-sender))
    (points-earned (get base-points category))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (get active category) err-invalid-input)
    
    ;; Create post record
    (map-set content-posts post-id {
      creator: tx-sender,
      title: title,
      description: description,
      content-type: content-type,
      content-url: content-url,
      likes: u0,
      shares: u0,
      post-date: stacks-block-height,
      monetized: false,
      verified: false
    })
    
    ;; Update profile
    (map-set creator-profiles tx-sender
      (merge profile {
        total-posts: (+ (get total-posts profile) u1),
        creator-level: (+ (get creator-level profile) (/ points-earned u25)),
        reputation-score: (+ (get reputation-score profile) u5),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award post creation tokens
    (try! (mint-tokens tx-sender reward-post))
    
    (var-set next-post-id (+ post-id u1))
    (print {action: "content-post-created", post-id: post-id, creator: tx-sender})
    (ok post-id)
  )
)

;; Like content post
(define-public (like-post (post-id uint))
  (let (
    (post (unwrap! (map-get? content-posts post-id) err-not-found))
    (creator-profile (get-or-create-profile (get creator post)))
  )
    (asserts! (not (is-eq tx-sender (get creator post))) err-unauthorized)
    (asserts! (is-none (map-get? post-interactions {post-id: post-id, user: tx-sender})) err-already-exists)
    
    ;; Record interaction
    (map-set post-interactions {post-id: post-id, user: tx-sender} {
      interaction-type: "like",
      interaction-date: stacks-block-height,
      tip-amount: u0
    })
    
    ;; Update post likes
    (map-set content-posts post-id
      (merge post {likes: (+ (get likes post) u1)})
    )
    
    ;; Update creator profile
    (map-set creator-profiles (get creator post)
      (merge creator-profile {
        total-likes: (+ (get total-likes creator-profile) u1),
        reputation-score: (+ (get reputation-score creator-profile) u2)
      })
    )
    
    ;; Award like tokens to creator
    (try! (mint-tokens (get creator post) reward-like))
    
    (print {action: "post-liked", post-id: post-id, liker: tx-sender, creator: (get creator post)})
    (ok true)
  )
)

;; Create collaboration project
(define-public (create-collaboration (project-title (string-ascii 64)) (project-description (string-ascii 200))
                                    (project-type (string-ascii 16)) (max-collaborators uint) (duration-days uint))
  (let (
    (collab-id (var-get next-collab-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len project-title) u0) err-invalid-input)
    (asserts! (> max-collaborators u0) err-invalid-input)
    (asserts! (and (>= duration-days u1) (<= duration-days u365)) err-invalid-input)
    (asserts! (>= (get creator-level profile) u3) err-unauthorized)
    
    (map-set collaboration-projects collab-id {
      initiator: tx-sender,
      project-title: project-title,
      project-description: project-description,
      project-type: project-type,
      max-collaborators: max-collaborators,
      current-collaborators: u0,
      duration-days: duration-days,
      start-date: stacks-block-height,
      end-date: (+ stacks-block-height duration-days),
      reward-pool: u0,
      active: true
    })
    
    (var-set next-collab-id (+ collab-id u1))
    (print {action: "collaboration-created", collab-id: collab-id, initiator: tx-sender})
    (ok collab-id)
  )
)

;; Join collaboration
(define-public (join-collaboration (collab-id uint) (role (string-ascii 16)))
  (let (
    (collab (unwrap! (map-get? collaboration-projects collab-id) err-not-found))
  )
    (asserts! (get active collab) err-invalid-input)
    (asserts! (< stacks-block-height (get end-date collab)) err-invalid-input)
    (asserts! (< (get current-collaborators collab) (get max-collaborators collab)) err-invalid-input)
    (asserts! (not (is-eq tx-sender (get initiator collab))) err-unauthorized)
    (asserts! (is-none (map-get? collaboration-participation {collab-id: collab-id, collaborator: tx-sender})) err-already-exists)
    
    ;; Add collaborator
    (map-set collaboration-participation {collab-id: collab-id, collaborator: tx-sender} {
      join-date: stacks-block-height,
      contribution-score: u0,
      role: role,
      completed: false
    })
    
    ;; Update collaboration count
    (map-set collaboration-projects collab-id
      (merge collab {current-collaborators: (+ (get current-collaborators collab) u1)})
    )
    
    (print {action: "collaboration-joined", collab-id: collab-id, collaborator: tx-sender, role: role})
    (ok true)
  )
)

;; Complete collaboration
(define-public (complete-collaboration (collab-id uint) (contribution-score uint))
  (let (
    (collab (unwrap! (map-get? collaboration-projects collab-id) err-not-found))
    (participation (unwrap! (map-get? collaboration-participation {collab-id: collab-id, collaborator: tx-sender}) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (get active collab) err-invalid-input)
    (asserts! (<= contribution-score u100) err-invalid-input)
    (asserts! (not (get completed participation)) err-invalid-input)
    
    ;; Update participation
    (map-set collaboration-participation {collab-id: collab-id, collaborator: tx-sender}
      (merge participation {
        contribution-score: contribution-score,
        completed: true
      })
    )
    
    ;; Update profile
    (map-set creator-profiles tx-sender
      (merge profile {
        collaborations: (+ (get collaborations profile) u1),
        reputation-score: (+ (get reputation-score profile) u15),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award collaboration tokens based on contribution
    (let (
      (reward-amount (+ reward-collaboration (/ (* contribution-score reward-collaboration) u100)))
    )
      (try! (mint-tokens tx-sender reward-amount))
    )
    
    (print {action: "collaboration-completed", collab-id: collab-id, collaborator: tx-sender, score: contribution-score})
    (ok true)
  )
)

;; Create creator event
(define-public (create-creator-event (event-title (string-ascii 64)) (event-type (string-ascii 16))
                                    (event-description (string-ascii 200)) (max-attendees uint) (ticket-price uint))
  (let (
    (event-id (var-get next-event-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len event-title) u0) err-invalid-input)
    (asserts! (> max-attendees u0) err-invalid-input)
    (asserts! (>= (get reputation-score profile) u150) err-unauthorized)
    
    (map-set creator-events event-id {
      host: tx-sender,
      event-title: event-title,
      event-type: event-type,
      event-description: event-description,
      max-attendees: max-attendees,
      current-attendees: u0,
      event-date: (+ stacks-block-height u720), ;; ~5 days from now
      ticket-price: ticket-price,
      active: true
    })
    
    (var-set next-event-id (+ event-id u1))
    (print {action: "creator-event-created", event-id: event-id, host: tx-sender})
    (ok event-id)
  )
)

;; Register for event
(define-public (register-for-event (event-id uint))
  (let (
    (event (unwrap! (map-get? creator-events event-id) err-not-found))
  )
    (asserts! (get active event) err-invalid-input)
    (asserts! (< (get current-attendees event) (get max-attendees event)) err-invalid-input)
    (asserts! (not (is-eq tx-sender (get host event))) err-unauthorized)
    (asserts! (is-none (map-get? event-attendance {event-id: event-id, attendee: tx-sender})) err-already-exists)
    
    ;; Register attendee
    (map-set event-attendance {event-id: event-id, attendee: tx-sender} {
      registration-date: stacks-block-height,
      attended: false,
      feedback-score: u0
    })
    
    ;; Update event attendance count
    (map-set creator-events event-id
      (merge event {current-attendees: (+ (get current-attendees event) u1)})
    )
    
    (print {action: "event-registered", event-id: event-id, attendee: tx-sender})
    (ok true)
  )
)

;; Create subscription tier
(define-public (create-subscription-tier (tier-name (string-ascii 16)) (tier-description (string-ascii 128))
                                        (monthly-price uint) (benefits (string-ascii 200)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len tier-name) u0) err-invalid-input)
    (asserts! (> monthly-price u0) err-invalid-input)
    (asserts! (>= (get creator-level profile) u5) err-unauthorized)
    (asserts! (is-none (map-get? subscription-tiers {creator: tx-sender, tier-name: tier-name})) err-already-exists)
    
    (map-set subscription-tiers {creator: tx-sender, tier-name: tier-name} {
      tier-description: tier-description,
      monthly-price: monthly-price,
      benefits: benefits,
      subscriber-count: u0,
      active: true
    })
    
    ;; Award subscription creation tokens
    (try! (mint-tokens tx-sender reward-subscription))
    
    (print {action: "subscription-tier-created", creator: tx-sender, tier-name: tier-name})
    (ok true)
  )
)

;; Claim creator milestone
(define-public (claim-creator-milestone (milestone (string-ascii 32)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? creator-milestones {creator: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "content-creator-50") (>= (get total-posts profile) u50)
        (if (is-eq milestone "viral-creator-1000") (>= (get total-likes profile) u1000)
        (if (is-eq milestone "collaboration-master-10") (>= (get collaborations profile) u10)
        (if (is-eq milestone "community-builder-100") (>= (get followers profile) u100)
        false)))))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set creator-milestones {creator: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        milestone-value: (get reputation-score profile),
        reward-earned: reward-milestone
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "creator-milestone-claimed", creator: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username and creator type
(define-public (update-profile (new-username (string-ascii 32)) (new-creator-type (string-ascii 16)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (asserts! (> (len new-creator-type) u0) err-invalid-input)
    (map-set creator-profiles tx-sender (merge profile {username: new-username, creator-type: new-creator-type}))
    (print {action: "profile-updated", creator: tx-sender, username: new-username, type: new-creator-type})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-creator-profile (creator principal))
  (map-get? creator-profiles creator)
)

(define-read-only (get-content-category (content-type (string-ascii 24)))
  (map-get? content-categories content-type)
)

(define-read-only (get-content-post (post-id uint))
  (map-get? content-posts post-id)
)

(define-read-only (get-post-interaction (post-id uint) (user principal))
  (map-get? post-interactions {post-id: post-id, user: user})
)

(define-read-only (get-collaboration-project (collab-id uint))
  (map-get? collaboration-projects collab-id)
)

(define-read-only (get-collaboration-participation (collab-id uint) (collaborator principal))
  (map-get? collaboration-participation {collab-id: collab-id, collaborator: collaborator})
)

(define-read-only (get-creator-event (event-id uint))
  (map-get? creator-events event-id)
)

(define-read-only (get-event-attendance (event-id uint) (attendee principal))
  (map-get? event-attendance {event-id: event-id, attendee: attendee})
)

(define-read-only (get-subscription-tier (creator principal) (tier-name (string-ascii 16)))
  (map-get? subscription-tiers {creator: creator, tier-name: tier-name})
)

(define-read-only (get-creator-milestone (creator principal) (milestone (string-ascii 32)))
  (map-get? creator-milestones {creator: creator, milestone: milestone})
)

;; Admin functions
(define-public (verify-post (post-id uint))
  (let (
    (post (unwrap! (map-get? content-posts post-id) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set content-posts post-id (merge post {verified: true}))
    (print {action: "post-verified", post-id: post-id})
    (ok true)
  )
)

(define-public (add-content-category (content-type (string-ascii 24)) (category-type (string-ascii 16))
                                    (base-points uint) (engagement-multiplier uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> (len content-type) u0) err-invalid-input)
    (asserts! (> base-points u0) err-invalid-input)
    (asserts! (and (>= engagement-multiplier u1) (<= engagement-multiplier u3)) err-invalid-input)
    
    (map-set content-categories content-type {
      category-type: category-type,
      base-points: base-points,
      engagement-multiplier: engagement-multiplier,
      active: true
    })
    
    (print {action: "content-category-added", content-type: content-type})
    (ok true)
  )
)