(setq user-full-name "Steph Samson"
      user-mail-address "ayo@kasteph.com"
      display-line-numbers-type t
      doom-theme 'doom-tokyo-night
      doom-font (font-spec :family "JetBrains Mono" :size 15 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Helvetica Neue" :size 15)
      fill-column 79
      require-final-newline t
      next-line-add-newlines nil)


(setq org-directory "~/Documents/org/"
      org-log-done 'time
      org-roam-directory (file-truename "~/Documents/org/roam/")
      org-roam-db-gc-threshold most-positive-fixnum
      org-startup-with-inline-images t)

(setq kasteph/bib `(,(expand-file-name "zotero.bib" org-directory)))

(after! org
  (setq org-agenda-files `("~/Documents/org/work.org"
                           "~/Documents/org/personal.org")
        org-ellipsis " ▼ "))

(after! org
  (setq org-capture-templates
        `(("w" "Work" entry (file "~/Documents/org/work.org")
           "* [ ] %?\n" :prepend t)
          ("p" "Personal" entry (file "~/Documents/org/personal.org")
           "* [ ] %?\n" :prepend t)
          ("n" "Notes" entry (file "~/Documents/org/notes.org")
           "* %?\n")
          ("s" "Slipbox" entry (file "~/Documents/org/roam/inbox.org")
           "* %?\n"))))

(defun kasteph/org-capture-slipbox()
  (interactive)
  (org-capture nil "s"))

(use-package! websocket
  :after org-roam)

(use-package! org-roam
  :init
  (map! :leader
        :prefix "n"
        :desc "kasteph/org-capture-slipbox" "<tab>" #'kasteph/org-capture-slipbox)
  :config
  (setq org-roam-capture-templates
        '(("m" "main" plain
           "%?"
           :if-new (file+head "main/${slug}.org"
                              "#+TITLE: ${title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("r" "reference" plain
           "%?"
           :if-new (file+head "references/${citar-citekey}.org"
                              "#+TITLE: ${citar-citekey} (${citar-date}). ${note-title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("a" "article" plain
           "%?"
           :if-new (file+head "articles/${title}.org"
                              "#+TITLE: ${title}\n#+FILETAGS: :article:\n")
           :immediate-finish t
           :unnarrowed t)))

  (defun kasteph/tag-new-node-as-draft ()
    (org-roam-tag-add '("draft")))
  (add-hook 'org-roam-capture-new-node-hook #'kasteph/tag-new-node-as-draft))


(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(after! bibtex-completion
  (setq! bibtex-completion-notes-path (concat org-roam-directory "references/")
         bibtex-completion-bibliography kasteph/bib
         bibtex-actions-bibliography kasteph/bib
         org-cite-global-bibliography kasteph/bib
         bibtex-completion-pdf-field "file"))

(after! bibtex-completion
  (after! org-roam
    (setq! bibtex-completion-notes-path org-roam-directory)))

(setq org-journal-dir "~/Documents/org/journal"
      org-journal-date-prefix "#+TITLE: "
      org-journal-time-prefix "* "
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-date-format "%a, %Y-%m-%d")

(setq! citar-org-roam-subdir "references"
       citar-notes-paths '(concat org-roam-directory "references/"
                           concat org-roam-directory "articles/"))

(after! citar
  (map! :map org-mode-map
        :desc "Insert citation" "C-c b" #'citar-insert-citation)
  (setq citar-bibliography kasteph/bib
        citar-at-point-function 'embark-act
        citar-symbol-separator "  "
        citar-format-reference-function 'citar-citeproc-format-reference
        org-cite-csl-styles-dir "~/Zotero/styles"
        citar-citeproc-csl-styles-dir org-cite-csl-styles-dir
        citar-citeproc-csl-locales-dir "~/Zotero/locales"
        citar-org-roam-capture-template-key "r"
        citar-citeproc-csl-style (file-name-concat org-cite-csl-styles-dir "mla.csl")))


(after! org-noter
  org-noter-doc-split-fraction '(0.57 0.43)
  org-noter-notes-search-path citar-notes-paths)

(setq lsp-pyls-server-command "/Users/kasteph/.local/bin/pylsp")

(setq epg-pinentry-mode `loopback)

(use-package reformatter
  :hook
  (python-mode . ruff-format-on-save-mode)
  (python-ts-mode . ruff-format-on-save-mode)
  :config
  (reformatter-define ruff-format
    :program "ruff"
    :args `("format" "--stdin-filename" ,buffer-file-name "-")))
