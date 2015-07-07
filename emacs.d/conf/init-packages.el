(require 'package)
(package-initialize)

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)

(defvar my-packages
  '(
    ace-jump-mode
    auto-package-update
    bundler
    company
    dash-at-point
    discover-my-major
    evil
    evil-surround
    expand-region
    git-gutter
    git-timemachine
    guide-key
    helm
    helm-ag
    helm-projectile
    magit
    neotree
    projectile
    rbenv
    restclient
    rinari
    rspec-mode
    rubocop
    smartparens
    wakatime-mode
    web-mode
    yaml-mode
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

(provide 'init-packages)
