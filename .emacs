;; Load CEDET.
;; See cedet/common/cedet.info for configuration details.
;; IMPORTANT: For Emacs >= 23.2, you must place this *before* any
;; CEDET component (including EIEIO) gets activated by another 
;; package (Gnus, auth-source, ...).
(load-file "~/.emacs.d/misc/cedet-1.1/common/cedet.el")

;; Enable EDE (Project Management) features
(global-ede-mode 1)

;; Enable EDE for a pre-existing C++ project
;; (ede-cpp-root-project "NAME" :file "~/myproject/Makefile")


;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:

;; * This enables the database and idle reparse engines
(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode,
;;   imenu support, and the semantic navigator
(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as intellisense mode,
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;; (semantic-load-enable-gaudy-code-helpers)

;; * This enables the use of Exuberant ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;; (semantic-load-enable-all-exuberent-ctags-support)
;;   Or, use one of these two types of support.
;;   Add support for new languages only via ctags.
;; (semantic-load-enable-primary-exuberent-ctags-support)
;;   Add support for using ctags as a backup parser.
;; (semantic-load-enable-secondary-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
(global-srecode-minor-mode 1)


;; ecb
(add-to-list 'load-path
	     "~/.emacs.d/misc/ecb-2.40")
(require 'ecb)
;(require 'ecb-autoloads)
(setq stack-trace-on-error nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cnblogs-blog-id "open_source")
 '(cnblogs-server-url "http://www.cnblogs.com/open_source/services/metaweblog.aspx")
 '(cnblogs-user-name "huwenbiao")
 '(cnblogs-user-passwd "huwenbiao")
 '(ecb-options-version "2.40")
 '(org-export-html-divs (quote ("preamble" "org-content" "postamble")))
 '(user-full-name "Hu Wenbiao")
 '(user-mail-address "huwenbiao1989@gmail.com"))

(setq org-export-html-content-div nil);虽然官方说这个变量将废弃，但代码中它仍然起作用，设为nil，使org-export-html-divs起作用
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;这里设置博客园软件
(load-file "~/hwb-notes/cnblogs/xml-rpc.el")
(load-file "~/hwb-notes/cnblogs/metaweblog.el")
(load-file "~/hwb-notes/cnblogs/cnblogs.el")
;(load-file "~/hwb-notes/cnblogs/tmp.el")




;; iimage mode
(autoload 'iimage-mode "iimage" "Support Inline image minor mode." t)
(autoload 'turn-on-iimage-mode "iimage" "Turn on Inline image minor mode." t)

(defun org-toggle-iimage-in-org ()
  "display images in your org file"
  (interactive)
  (if (face-underline-p 'org-link)
      (set-face-underline-p 'org-link nil)
    (set-face-underline-p 'org-link t))
  (iimage-mode))

;; 下面设置 org-mode

(setq org-publish-project-alist
      `(("note-org"
         :base-directory "~/hwb-notes/Org"
         :publishing-directory "~/Publish"
         :base-extension "org"
         :recursive t
         :publishing-function org-publish-org-to-html
         :auto-index t
         :index-filename "index.org"
         :index-title "index"
         :link-home "index.html"
;	 :style "<link rel=\"stylesheet\" href=\"/home/huwenbiao/note/Publish/style/emacs.css\" type=\"text/css\"/>"
)

	
        ("note-static"
         :base-directory "~/hwb-notes/Org"
         :publishing-directory "~/Publish"
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|zip\\|gz\\|txt\\|el"
         :publishing-function org-publish-attachment)
	("note"
	 :components ("note-org" "note-static")
	 )))
; 显示图片
(setq org-startup-with-inline-images t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;  下面的都是自己单独安装的，在misc文件夹中  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq load-path (cons "~/.emacs.d/misc" load-path))

;; htmlize可以将代码围成高亮的html，org可以利用它来产生高亮的代码
(require 'htmlize)

;; 加载graphviz
(load-file "~/.emacs.d/misc/graphviz-dot-mode.el")
;; 设置graphviz，也可以设置org-babel-load-language的值
(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t)
   (asymptote . t)
   ))

; Do not prompt to confirm evaluation
; This may be dangerous - make sure you understand the consequences
; of setting this -- see the docstring for details
; 设置计算dot, asymptote等代码时不用提示，要不然文章中带插图时提示太烦人
(setq org-confirm-babel-evaluate nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 设置w3m图片显示
(setq w3m-default-display-inline-images t)

;;下面设置mew
(setq load-path (cons "/usr/local/share/emacs/site-lisp/mew" load-path));这个是安装的位置，家目录下的那个没用，make uninstall删除时用的
(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

;; Optional setup (Read Mail menu):
(setq read-mail-command 'mew)

;; Optional setup (e.g. C-xm for sending a message):
(autoload 'mew-user-agent-compose "mew" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))

;;;;;;;;;;;;;;;;;;;;;;;;;
(setq mew-name "Gmail")
(setq mew-user "huwenbiao1989")
(setq mew-mail-domain "gmail.org")

(setq mew-mailbox-type 'mbox)
(setq mew-mbox-command "incm")
(setq mew-mbox-command-arg (concat "-u -d "
                                   (expand-file-name "~/Mail/inbox/")))


