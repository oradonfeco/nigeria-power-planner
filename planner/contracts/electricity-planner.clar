;; Load Shedding Copilot (Electricity Planner)
;; A smart contract to help Nigerian users plan electricity usage during outages
;; Author: v0

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-USER-EXISTS (err u101))
(define-constant ERR-USER-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))

;; Data maps
(define-map users 
  { user-id: principal }
  {
    name: (string-utf8 50),
    location: (string-utf8 100),
    meter-type: (string-utf8 20),
    meter-number: (string-utf8 30),
    daily-kwh-usage: uint,
    has-generator: bool,
    generator-capacity: uint,
    has-solar: bool,
    solar-capacity: uint,
    created-at: uint
  }
)

(define-map power-outages
  { location: (string-utf8 100), date: uint }
  {
    start-time: uint,
    end-time: uint,
    reported-by: principal,
    confirmed-count: uint
  }
)

(define-map electricity-usage
  { user-id: principal, date: uint }
  {
    grid-kwh: uint,
    generator-kwh: uint,
    solar-kwh: uint,
    grid-cost: uint,
    generator-cost: uint,
    total-hours-without-power: uint
  }
)

(define-map recommendations
  { user-id: principal }
  {
    optimal-generator-runtime: uint,
    optimal-solar-usage: uint,
    estimated-savings: uint,
    last-updated: uint
  }
)

;; Public functions

;; Register a new user
(define-public (register-user 
                (name (string-utf8 50))
                (location (string-utf8 100))
                (meter-type (string-utf8 20))
                (meter-number (string-utf8 30))
                (daily-kwh-usage uint)
                (has-generator bool)
                (generator-capacity uint)
                (has-solar bool)
                (solar-capacity uint))
  (let ((user-exists (is-some (map-get? users { user-id: tx-sender }))))
    (if user-exists
      ERR-USER-EXISTS
      (begin
        (map-set users
          { user-id: tx-sender }
          {
            name: name,
            location: location,
            meter-type: meter-type,
            meter-number: meter-number,
            daily-kwh-usage: daily-kwh-usage,
            has-generator: has-generator,
            generator-capacity: generator-capacity,
            has-solar: has-solar,
            solar-capacity: solar-capacity,
            created-at: stacks-block-height
          }
        )
        (ok true)
      )
    )
  )
)

;; Update user profile
(define-public (update-user-profile
                (name (string-utf8 50))
                (location (string-utf8 100))
                (meter-type (string-utf8 20))
                (meter-number (string-utf8 30))
                (daily-kwh-usage uint)
                (has-generator bool)
                (generator-capacity uint)
                (has-solar bool)
                (solar-capacity uint))
  (let ((user-data (map-get? users { user-id: tx-sender })))
    (if (is-none user-data)
      ERR-USER-NOT-FOUND
      (begin
        (map-set users
          { user-id: tx-sender }
          {
            name: name,
            location: location,
            meter-type: meter-type,
            meter-number: meter-number,
            daily-kwh-usage: daily-kwh-usage,
            has-generator: has-generator,
            generator-capacity: generator-capacity,
            has-solar: has-solar,
            solar-capacity: solar-capacity,
            created-at: (get created-at (unwrap-panic user-data))
          }
        )
        (ok true)
      )
    )
  )
)

;; Report a power outage
(define-public (report-power-outage
                (location (string-utf8 100))
                (date uint)
                (start-time uint)
                (end-time uint))
  (let ((outage-data (map-get? power-outages { location: location, date: date })))
    (if (is-some outage-data)
      ;; Update existing outage with confirmation
      (let ((current-outage (unwrap-panic outage-data)))
        (map-set power-outages
          { location: location, date: date }
          {
            start-time: (get start-time current-outage),
            end-time: (get end-time current-outage),
            reported-by: (get reported-by current-outage),
            confirmed-count: (+ (get confirmed-count current-outage) u1)
          }
        )
        (ok true)
      )
      ;; Create new outage report
      (begin
        (map-set power-outages
          { location: location, date: date }
          {
            start-time: start-time,
            end-time: end-time,
            reported-by: tx-sender,
            confirmed-count: u1
          }
        )
        (ok true)
      )
    )
  )
)

;; Record electricity usage
(define-public (record-electricity-usage
                (date uint)
                (grid-kwh uint)
                (generator-kwh uint)
                (solar-kwh uint)
                (grid-cost uint)
                (generator-cost uint)
                (total-hours-without-power uint))
  (let ((user-exists (is-some (map-get? users { user-id: tx-sender }))))
    (if (not user-exists)
      ERR-USER-NOT-FOUND
      (begin
        (map-set electricity-usage
          { user-id: tx-sender, date: date }
          {
            grid-kwh: grid-kwh,
            generator-kwh: generator-kwh,
            solar-kwh: solar-kwh,
            grid-cost: grid-cost,
            generator-cost: generator-cost,
            total-hours-without-power: total-hours-without-power
          }
        )
        (ok true)
      )
    )
  )
)

;; Generate recommendations for optimal electricity usage
(define-public (generate-recommendations)
  (let ((user-data (map-get? users { user-id: tx-sender })))
    (if (is-none user-data)
      ERR-USER-NOT-FOUND
      (let ((user (unwrap-panic user-data)))
        ;; This is a simplified algorithm - in a real implementation, 
        ;; this would analyze historical usage patterns and outage data
        (let ((optimal-generator-runtime (if (get has-generator user) 
                                           (if (> (get generator-capacity user) u0)
                                             (/ (get daily-kwh-usage user) (get generator-capacity user))
                                             u0)
                                           u0))
              (optimal-solar-usage (if (get has-solar user)
                                     (if (> (get solar-capacity user) u0)
                                       (/ (get daily-kwh-usage user) (get solar-capacity user))
                                       u0)
                                     u0))
              (estimated-savings (+ (* optimal-generator-runtime u10) (* optimal-solar-usage u15))))
          
          (map-set recommendations
            { user-id: tx-sender }
            {
              optimal-generator-runtime: optimal-generator-runtime,
              optimal-solar-usage: optimal-solar-usage,
              estimated-savings: estimated-savings,
              last-updated: stacks-block-height
            }
          )
          (ok true)
        )
      )
    )
  )
)

;; Read-only functions

;; Get user profile
(define-read-only (get-user-profile (user-id principal))
  (map-get? users { user-id: user-id })
)

;; Get power outage information
(define-read-only (get-power-outage (location (string-utf8 100)) (date uint))
  (map-get? power-outages { location: location, date: date })
)

;; Get electricity usage for a specific date
(define-read-only (get-electricity-usage (user-id principal) (date uint))
  (map-get? electricity-usage { user-id: user-id, date: date })
)

;; Get recommendations for a user
(define-read-only (get-user-recommendations (user-id principal))
  (map-get? recommendations { user-id: user-id })
)

;; Get average outage duration for a location
(define-read-only (get-average-outage-duration (location (string-utf8 100)))
  ;; This is a placeholder - in a real implementation, this would calculate
  ;; the average based on historical data
  (ok u240) ;; Return 4 hours as an example
)

;; Get estimated cost savings from optimal usage
(define-read-only (get-estimated-savings (user-id principal))
  (let ((rec (map-get? recommendations { user-id: user-id })))
    (if (is-some rec)
      (ok (get estimated-savings (unwrap-panic rec)))
      (err u0)
    )
  )
)