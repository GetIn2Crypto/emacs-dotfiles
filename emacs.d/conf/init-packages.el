;; init-packages.el --- List and management of my packages

;;; commentary:
;; That file contains my-packages list and a dolist function that install each package
;; This idea of managing packages was stolen from: https://github.com/rranelli/emacs-dotfiles

;;; code:

(defvar my-packages
  '(
    ace-window
    achievements
    alchemist
    all-the-icons
    all-the-icons-ivy
    all-the-icons-dired
    apropospriate-theme
    avy
    bundler
    cider
    challenger-deep-theme
    clojure-mode
    clojure-mode-extra-font-locking
    company
    company-emoji
    discover-my-major
    docker
    doom-themes
    easy-kill
    edit-server
    elfeed
    elfeed-org
    enh-ruby-mode
    flycheck
    flycheck-pos-tip
    flycheck-clojure
    flycheck-credo
    free-keys
    gist
    git-gutter
    git-gutter-fringe
    git-timemachine
    google-this
    google-translate
    haskell-mode
    highlight
    hl-anything
    hydra
    ido-vertical-mode
    instapaper
    imenu-list
    ivy-youtube
    iy-go-to-char
    json-navigator
    langtool
    ledger-mode
    lua-mode
    magit
    magithub
    markdown-mode+
    mutant
    ob-restclient
    ob-sml
    org-bullets
    org-gcal
    ox-twbs
    pdf-tools
    projectile
    projectile-rails
    counsel-projectile
    rainbow-mode
    rbenv
    request
    restart-emacs
    restclient
    rhtml-mode
    rspec-mode
    rubocop
    ruby-refactor
    ruby-tools
    symbol-overlay
    smartparens
    smex
    sml-mode
    swiper
    tagedit
    telephone-line
    try
    twittering-mode
    wakatime-mode
    web-mode
    which-key
    yaml-mode
    zeal-at-point
    yasnippet
    wgrep
  )
  "A list of packages to be installed at application lauch.")

;; package loading (stolen from chuck that stoled from milhouse)
(setq packaged-contents-refreshed-p nil)
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (condition-case ex
  (package-install p)
  ('error (if packaged-contents-refreshed-p
      (error ex)
    (package-refresh-contents)
    (setq packaged-contents-refreshed-p t)
    (package-install p))))))

(require 'init-simple-packages)

(provide 'init-packages)
;;; init-packages ends here
