(require 'rinari)
(require 'rspec-mode)

;; do not add encoding comment automatically
(setq ruby-insert-encoding-magic-comment nil)

;; this hook enable debug in rspec-mode
(add-hook 'after-init-hook 'inf-ruby-switch-setup)

;; rspec-mode configuration

(setq rspec-use-rake-when-possible nil)
(setq rspec-use-spring-when-possible nil)
(setq compilation-scroll-output t)
(add-hook 'dired-mode-hook 'rspec-dired-mode)

;; auto modes
(dolist (fp '("\\.rb$"
	      "\\.ru$"
              "\\.rake"
	      "\\.jbuilder$"
	      "\\.gemspec$"
	      "\\GuardFile$"
	      "\\Rakefile$"
	      "\\Vagrantfile$"
	      "\\Gemfile$"
	      "\\Godfile$"
	      "\\.god$"))
  (add-to-list 'auto-mode-alist `(,fp . ruby-mode)))

(require 'rubocop)

;; Rubocop
(add-hook 'ruby-mode-hook 'rubocop-mode)

;;open the spec of a class
(defun senny-ruby-open-spec-other-buffer ()
  (interactive)
  (when (featurep 'rspec-mode)
    (let ((source-buffer (current-buffer))
          (other-buffer (progn
                          (rspec-toggle-spec-and-target)
                          (current-buffer))))
      (switch-to-buffer source-buffer)
      (pop-to-buffer other-buffer))))

;; String interpolation
(defun senny-ruby-interpolate ()
  "In a double quoted string, interpolate."
  (interactive)
  (insert "#")
  (when (and
         (looking-back "\".*")
         (looking-at ".*\""))
    (insert "{}")
    (backward-char 1)))

;; vcr toggle
(defun custom/vcr-toggle ()
  (interactive)
  (if (getenv "VCR_OFF")
      (progn
        (setenv "VCR_OFF" nil)
        (message "VCR is ON"))
    (setenv "VCR_OFF" "true")
    (message "VCR is OFF")))

(eval-after-load 'ruby-mode
  '(progn
     (define-key ruby-mode-map (kbd "C-c , ,") 'senny-ruby-open-spec-other-buffer)
     (define-key ruby-mode-map (kbd "#") 'senny-ruby-interpolate)
     (define-key ruby-mode-map (kbd "C-, b e") 'bundle-exec)
     (define-key ruby-mode-map (kbd "C-, b i") 'bundle-install)
     (define-key ruby-mode-map (kbd "C-, b o") 'bundle-open)
     (define-key ruby-mode-map (kbd "C-, b c") 'bundle-console)
     (define-key ruby-mode-map (kbd "C-c v") 'custom/vcr-toggle)))

(provide 'init-ruby)
