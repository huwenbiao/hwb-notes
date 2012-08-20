;;; entry type
;;
;; (id title postid categories src-file state)

(defgroup cnblogs nil
  "����԰�ͻ��˷���"
  :group 'emacs)

(defun cnblogs-define-variables () ;; todo: �����Ժ�Ҫ�ĳ�nil
  "���弰��ʼ��������"
  (defcustom cnblogs-server-url nil
    "MetaWeblog���ʵ�ַ"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-blog-id nil
    "����ID"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-user-name nil
    "��¼�û���"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-user-passwd nil
    "�û�����"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-media-object-suffix-list '("jpg" "jpeg" "png" "gif" "mp4")
    "ϣ�������ý���ļ�����"
    :group 'cnblogs
    :type 'list)
  (defcustom cnblogs-template-head
    "#TITLE:    \n#KEYWORDS: \n#DATE:    \n"
    "����ͷģ��"
    :group 'cnblogs)
  :type 'list
  (defcustom cnblogs-file-root-path "~/.Cnblogs/"
    "�����ļ��ĸ�Ŀ¼"
    :group 'cnblogs
    :type 'string)

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (defvar cnblogs-posts-in-category nil
    "����֮��Ĳ��ģ�������ʾ��Cnblogs-Manager�����������Ҫ����")
  (defvar cnblogs-entry-list-file
    (concat cnblogs-file-root-path "entry-list-file")
    "�������б��ļ�")
  (defvar cnblogs-file-post-path
    (concat cnblogs-file-root-path "post/")
    "���������ļ���Ŀ¼�����еĲ��������ļ��Բ��ģ������")
  (defvar cnblogs-category-list nil
    "���ķ����б�")
  (defvar cnblogs-category-list-file 
    (concat cnblogs-file-root-path "category-list-file")
    "���ķ����б�")
  (defvar cnblogs-blog-info nil
    "������Ϣ")
  (defvar cnblogs-entry-list nil
    "���ز����б�")
  (defvar cnblogs-category-list nil
    "�����б�")
  (defvar cnblogs-post-list-window nil
    "�����б���")
  (setq  test-post  `(("title" . "������Ŀ") 
		      ("dateCreated" :datetime (20423 52590))
		      ("categories"  "categories" "[��ʷ���]Emacs" "[��ʷ���]LinuxӦ��")
		      ("description" . "�������ġ�")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;Menu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (defvar cnblogs-mode-map
    (make-sparse-keymap "Cnblogs")
    "cnblogs���Ϳͻ��˲˵�")

  (define-key cnblogs-mode-map [tags-getUsersBlogs]
    '(menu-item "�û���Ϣ" cnblogs-get-users-blogs
		:help "��ȡ�û��Ĳ�����Ϣ"))

  (define-key cnblogs-mode-map [tags-getRecentPosts]
    '(menu-item "��ȡ�������" cnblogs-get-recent-posts
		:help "��ȡ���������Nƪ����"))

  (define-key cnblogs-mode-map [tags-getCategories]
    '(menu-item "��ȡ�����£�����" cnblogs-get-categories
		:help "��ȡ�����±��ز��ͷ���"))

  (define-key cnblogs-mode-map [tags-getPost]
    '(menu-item "��ȡ����" cnblogs-get-post
		:help "��ȡ�����±���ָ���Ĳ���"))
  (define-key cnblogs-mode-map [separator-cnblogs-tags]
    '(menu-item "--"))

  (define-key cnblogs-mode-map [tags-editPost]
    '(menu-item "����" cnblogs-edit-post
		:help "�����ѷ����Ĳ���"))

  (define-key cnblogs-mode-map [tags-deletePost]
    '(menu-item "ɾ��" cnblogs-delete-post
		:help "����ǰ��������Ӧ�Ĳ���ɾ��"))

  (define-key cnblogs-mode-map [tags-saveDraft]
    '(menu-item "���" cnblogs-save-draft
		:help "���ݸ屣�浽����������״̬Ϊ��δ������"))

  (define-key cnblogs-mode-map [tags-newPost]
    '(menu-item "����" cnblogs-new-post
		:help "������ǰ������"))

  (define-key cnblogs-mode-map [C-S-mouse-1]
    cnblogs-mode-map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;KeyMap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define-key cnblogs-mode-map (kbd "\C-c c p") 'cnblogs-new-post)
  (define-key cnblogs-mode-map (kbd "\C-c c s") 'cnblogs-save-draft)
  (define-key cnblogs-mode-map (kbd "\C-c c d") 'cnblogs-delete-post)
  (define-key cnblogs-mode-map (kbd "\C-c c e") 'cnblogs-edit-post)
  (define-key cnblogs-mode-map (kbd "\C-c c g") 'cnblogs-get-post)
  (define-key cnblogs-mode-map (kbd "\C-c c c") 'cnblogs-get-categories)
  (define-key cnblogs-mode-map (kbd "\C-c c r") 'cnblogs-get-recent-posts)
  (define-key cnblogs-mode-map (kbd "\C-c c u") 'cnblogs-get-users-blogs)
  )

					;(cnblogs-define-variables)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LoadData;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun cnblogs-load-variables ()
  "���ظ�������ֵ";
					;���ز������б�
  (cnblogs-load-entry-list)
					;���ز��ķ���
  (cnblogs-load-category-list)
					;���������б��е�����뵽��Ӧ�ķ�����ȥ
  (mapc (lambda (categorie)
	  (progn
					;�Ƚ��÷������
	    (push (cons categorie nil)
		  cnblogs-posts-in-category)
	    )
	  
					;�����ڸ÷���������÷���
	  (mapc (lambda (entry)
		  (let* ((entry-categories (nth 3 entry))
			 (flag (member categorie entry-categories)))
		    (and flag
			 (push entry
			       (cdr (assoc categorie cnblogs-posts-in-category)))))
		  )
		
		cnblogs-entry-list))

	cnblogs-category-list)
  )

;(cnblogs-load-entry-list) ;; todo: ���ڳ�ʼ���У����ͽ����庯������ǰ��
(defun cnblogs-load-entry-list ()
  (setq cnblogs-entry-list
	(condition-case ()
	    (with-temp-buffer
	      (insert-file-contents cnblogs-entry-list-file)
	      (car (read-from-string (buffer-string))))
	  (error nil))))

(defun cnblogs-save-entry-list () 
  (with-temp-file cnblogs-entry-list-file
    (print cnblogs-entry-list
	   (current-buffer))))


(defun cnblogs-load-category-list ()
  (setq cnblogs-category-list
	(condition-case ()
	    (with-temp-buffer
	      (insert-file-contents cnblogs-category-list-file)
	      (car (read-from-string (buffer-string))))
	  (error nil))))

(defun cnblogs-save-category-list ()
					;�Ƚ������ʽ�򻯣�ֻ��ȡ����
  (setq cnblogs-category-list
	(mapcar (lambda (category)
		  (cdr (assoc "description" category))
		  )
		cnblogs-category-list))
  (with-temp-file cnblogs-category-list-file
    (print cnblogs-category-list
	   (current-buffer))))


(defun cnblogs-setup-blog ()
  (interactive)
  (setq cnblogs-blog-id
	(read-string "������Ĳ���ID��" nil nil))
  (setq cnblogs-user-name
	(read-string "��������û�����" nil nil))
  (setq cnblogs-user-passwd
	(read-passwd "����������룺" nil ))
  (setq cnblogs-server-url
	(concat "http://www.cnblogs.com/"
		cnblogs-blog-id
		"/services/metaweblog.aspx"))
  (setq cnblogs-category-list
	(cnblogs-metaweblog-get-categories))
  (setq cnblogs-blog-info
	(cnblogs-metaweblog-get-users-blogs))
  (if cnblogs-blog-info
      (progn
	(customize-save-variable 'cnblogs-blog-id  cnblogs-blog-id)
	(customize-save-variable 'cnblogs-user-name cnblogs-user-name)
	(customize-save-variable 'cnblogs-user-passwd cnblogs-user-passwd)
	(customize-save-variable 'cnblogs-server-url cnblogs-server-url)
	;; ���û��.CnblogsĿ¼�����½����Ŀ¼
	(or (file-directory-p "~/.Cnblogs")
	    (make-directory "~/.Cnblogs"))
	(cnblogs-save-category-list)
	(message "���óɹ�"))
    (message "����ʧ��")))

(defun cnblogs-fetch-field (field)
  (let* ((regexp
	  (concat "^[ \t]*[#]+[\\+]?"
		  field
		  ":[^\n]*"))
	 (idx (string-match regexp 
			    (buffer-substring-no-properties (point-min)
							    (point-max)))))
    (if idx
	(let* ((field-val (match-string  0 
					 (buffer-substring-no-properties (point-min) 
									 (point-max))))
	       (val (substring field-val
			       (1+ (string-match  ":"  field-val))))
	       (idx2 (string-match "[^ \t]+"
				   val)))
	  (and idx2
	       (substring val
			  idx2)))
      nil)))


(defun cnblogs-categories-string-to-list (categories-string)
  "�������ַ������հ׷��ֳ��ַ����б�"
  (if (or (eq categories-string nil)
	  (eq categories-string ""))
      nil
    (let ((idx1
	   (string-match "[^�� \t]+"    ;Բ�ǰ�ǿո�
			 categories-string)))
      (if (not idx1)
	  nil
	(setq categories-string         ;Բ�ǰ�ǿո�
	      (substring categories-string idx1))
	(let ((idx2 
	       (string-match "[�� \t]+"
			     categories-string)))
	  (if idx2
	      (cons (concat "[��ʷ���]"
			    (substring categories-string 
				       0
				       idx2))
		    (cnblogs-categories-string-to-list (substring categories-string
								  idx2)))
	    (cons (concat "[��ʷ���]"
			  categories-string)
		  nil)))))))

(defun cnblogs-insert-template-head ()
  "����ͷģ��"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (insert cnblogs-template-head)))

(defun cnblogs-make-media-object-file-data (media-path) ;todo: type�Ժ����
  "���ݸ������ļ�·��������Ӧ��FileData���ļ������ڷ���nil"
  (and (file-exists-p media-path)
       (list
	;;media-path name
	(cons "name" 
	      (file-name-nondirectory media-path))
	
	;; bits
	(cons "bits"
	      (base64-encode-string
	       (with-temp-buffer
		 (insert-file-contents-literally media-path)
		 (buffer-string)))))))



(defun cnblogs-replace-media-object-location (buf-str)
  "����BUF-STR�е�ý���ļ������ش������ַ���"
  (mapc (lambda (suffix)
	  (let ((regexp 
		 (concat "[a-z]?[:]?[^:*\"?<>|]+."
			 suffix))
		(current 0))
	    (while (string-match regexp
				 buf-str
				 current)
	      (let* ((media-path (match-string 0
					       buf-str))
		     (media-url
		      (save-match-data
			(or
			 (and (file-exists-p media-path)
			      (cnblogs-metaweblog-new-media-object 
			       (cnblogs-make-media-object-file-data
				media-path)))
			 (and (file-exists-p (substring media-path 1))
			      (cnblogs-metaweblog-new-media-object 
			       (cnblogs-make-media-object-file-data (substring
								     media-path 1))))))))
		
		(if media-url
		    (progn
		      (setq current
			    (+ (match-beginning 0)
			       (length media-url)))
		      (setq buf-str
			    (replace-match media-url
					   t
					   t
					   buf-str)))
		  (setq current
			(match-end 0)))))))
	cnblogs-media-object-suffix-list)
  buf-str)

(defun cnblogs-org-mode-buffer-to-post ()
  (delq nil(list
	    ;; title
	    (cons "title"
		  (or (cnblogs-fetch-field "TITLE")
		      "�����"))

	    ;; categories
	    (cons "categories"
		  (let ((categories-list
			 (cnblogs-categories-string-to-list
			  (cnblogs-fetch-field "KEYWORDS"))))
		    (or
		     categories-list
		     '("[��ʷ���]δ����"))))

	    ;; dateCreated
	    (cons "dateCreated"
		  (list 
		   :datetime
		   (condition-case ()
		       (date-to-time (cnblogs-fetch-field "DATE")) ;todo: Ҫת��
		     (error (progn
			      (message "ʱ���ʽ��֧�֣�ʹ��Ĭ��ʱ��:1989-05-17 00:00")
			      (date-to-time "1989-05-17 00:00"))))))

	    ;; description
	    (cons "description"
		  (with-current-buffer  (org-export-as-html-to-buffer 3)
		    (let ((buf-str 
			   (cnblogs-replace-media-object-location
			    (buffer-substring-no-properties 
			     (point-min)
			     (point-max)))))
		      (kill-buffer)
		      buf-str))))))

(defun cnblogs-other-mode-buffer-to-post () ;todo: post������ȫ
  (delq nil
	(list
	 ;; title
	 (cons "title"
	       (or (cnblogs-fetch-field "TITLE")
		   "�����"))
	 
	 
	 ;; categories
	 (cons "categories"
	       (let ((categories-list
		      (cnblogs-categories-string-to-list
		       (cnblogs-fetch-field "KEYWORDS"))))
		 (or
		  categories-list
		  '("[��ʷ���]δ����"))))

	 
	 ;; dateCreated
	 (cons "dateCreated"
	       (list 
		:datetime
		(condition-case ()
		    (date-to-time (cnblogs-fetch-field "DATE")) ;todo: Ҫת��
		  (error (progn
			   (message "ʱ���ʽ��֧�֣�ʹ��Ĭ��ʱ��:1989-05-17 00:00")
			   (date-to-time "1989-05-17 00:00"))))))
	 ;; description
	 (cons "description"
	       (cnblogs-replace-media-object-location
		(buffer-substring-no-properties
		 (cnblogs-point-template-head-end)
		 (point-max)))))))


(defun cnblogs-point-template-head-end ()
  (print  (save-excursion
	    (goto-char (point-min))
	    (forward-paragraph)
	    (point))))


(defun cnblogs-current-buffer-to-post ()
  (cond
   ((equal mode-name
	   "Org")
    (cnblogs-org-mode-buffer-to-post))
   
   (t
    (cnblogs-other-mode-buffer-to-post))))




(defun cnblogs-new-post ()
  (interactive)
  
  (let ((post-id  ;�õ����ģ��
	 (cnblogs-metaweblog-new-post (cnblogs-current-buffer-to-post)
				      t))
					;�õ���������
	(post-content
	 (cnblogs-metaweblog-get-post post-id)))
					;�����µĲ������б�
					;todo:����Ҫˢ���б�
    (setq cnblogs-entry-list
	  (cons (cnblogs-make-entry post-content)
		cnblogs-entry-list))
					;���沩�����ݣ��ļ���Ϊ���ģ��
    (with-temp-file (concat cnblogs-file-post-path post-id)
      (print post-content
	     (current-buffer)))
					;���沩�����б�
    (cnblogs-save-entry-list))
  (message "������ʳɹ���"))



(defun cnblogs-save-draft ()
  (interactive)
  (let ((post-id  
	 (cnblogs-metaweblog-new-post (cnblogs-current-buffer-to-post)
				      nil)))
    (setq cnblogs-entry-list
	  (cons
	   (cnblogs-metaweblog-get-post post-id)
	   cnblogs-entry-list))
    (cnblogs-save-entry-list))
  (message "����ݸ�ɹ���"))

(defun cnblogs-delete-post-from-entry-list (blog-id) 
  "POST-ID��string����"
  (condition-case ()
      (progn
	(setq cnblogs-entry-list
	      (remove-if (lambda (post)
			   (let ((item (assoc "postid"
					      post)))
			     (and item
				  (equal blog-id
					 (if (stringp (cdr item))
					     (cdr item)
					   (int-to-string(cdr item)))))))
			 cnblogs-entry-list))
	t)
    (error nil)))



(defun cnblogs-get-blog-id-by-title (title)
  (and (stringp title)
       (let ((post-id nil))
	 (mapc (lambda (post)
		 (or post-id
		     (and (equal title
				 (cdr (assoc "title"
					     post)))
			  (setq post-id 
				(cdr (assoc "postid"
					    post))))))
	       cnblogs-entry-list)
	 (and post-id
	      (int-to-string post-id)))))

(defun cnblogs-delete-post ();todo:���ر���
  (interactive)
  (let ((blog-id
	 (cnblogs-get-blog-id-by-title
	  (cnblogs-fetch-field "title"))))
    (if (and blog-id
	     (yes-or-no-p "���ɾ����������ϢҲ��ɾ����ȷ��Ҫɾ����")
	     (cnblogs-metaweblog-delete-post blog-id t)
	     (cnblogs-delete-post-from-entry-list blog-id))
	(message "ɾ���ɹ���")
      (message "ɾ��ʧ�ܣ�"))))


(defun cnblogs-edit-post ();;todo:���±���
  (interactive)
  (let ((blog-id
	 (cnblogs-get-blog-id-by-title
	  (cnblogs-fetch-field "title"))))
    (if (and blog-id
	     (yes-or-no-p "ȷ��Ҫ������")
	     (cnblogs-metaweblog-edit-post blog-id
					   (cnblogs-current-buffer-to-post)
					   t))
	(message "���³ɹ���")
      (message "����ʧ�ܣ�"))))

(defun cnblogs-get-post ()
  (interactive)
  (let* ((post-id
	  (read-string "����Ҫ��ȡ�����ID��"))
	 (post
	  (condition-case ()
	      (cnblogs-metaweblog-get-post post-id)
	    (error nil))))
    (if (and post-id
	     (cnblogs-delete-post-from-entry-list post-id)
	     post
	     (setq cnblogs-entry-list
		   (cons post cnblogs-entry-list)))
	(message "��ȡ�ɹ���")
      (message "��ȡʧ��"))))

;; ��ȡ���������
(defun cnblogs-get-categories ()
  (interactive)
  (setq cnblogs-category-list
	(condition-case ()
	    (cnblogs-metaweblog-get-categories)
	  (error nil)))
  (if cnblogs-category-list
      (progn
	(cnblogs-save-category-list)
	(message "��ȡ����ɹ���"))
    (message "��ȡ����ʧ��")))




(defun cnblogs-get-recent-posts ()
  (interactive)
  (let* ((num (read-number "����Ҫ��ȡ�����ƪ����"
			   1))
	 (posts (condition-case ()
		    (cnblogs-metaweblog-get-recent-posts num)
		  (error nil))))
    (if (not posts)
	(message "��ȡʧ�ܣ�")
      (progn
	(mapc (lambda (post)
		(let ((post-id (cdr 
				(assoc "postid"
				       post))))
		  (and post-id
		       (cnblogs-delete-post-from-entry-list post-id))
		  (setq cnblogs-entry-list
			(cons post
			      cnblogs-entry-list))))
	      posts)
	(cnblogs-save-entry-list)
	(message "��ȡ�ɹ���")))))

(defun cnblogs-get-users-blogs ()
  (interactive)
  (setq cnblogs-blog-info
	(condition-case ()
	    (prog1
		(cnblogs-metaweblog-get-users-blogs)
	      (message "��ȡ�û�������Ϣ�ɹ���"))
	  (error cnblogs-blog-info))))





;; �����ǹ���minor mode������
(defun cnblogs-init ()
  "Cnblogs�����г�ʼ������"
  (cnblogs-define-variables)
  (cnblogs-load-variables)
  )

(cnblogs-init)

(define-key cnblogs-mode-map [menu-bar menu-bar-cnblogs-menu]
  (cons "Cnblogs" cnblogs-mode-map))

(define-minor-mode cnblogs-minor-mode
  "cnblogs-minor-mode"
  :init-value nil
  :lighter " Cnblogs"
  :keymap cnblogs-mode-map
  :group Cnblogs)
