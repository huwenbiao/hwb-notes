(defgroup cnblogs nil
  "����԰�ͻ��˷���"
  :group 'emacs)
(defun cnblogs-init () ;; todo: �Ժ�Ҫ�ĳ�nil
  "��ʼ��������"
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
    :type 'list
    :group 'cnblogs)
  
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (defvar cnblogs-blog-info nil
    "������Ϣ")
  (defvar cnblogs-entry-list nil
    "���ز����б�")
  (defvar cnblogs-category-list nil
    "�����б�")
  (defvar cnblogs-manager-window nil
    "���͹�����")
  (setq  test-post  `(("title" . "test of my blog client") 
		      ("dateCreated" :datetime (20423 52590))
		      ("categories"  "categories" "[��ʷ���]Emacs" "[��ʷ���]LinuxӦ��")
		      ("description" . "�������")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;Menu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (defvar menu-bar-cnblogs-menu
    (make-sparse-keymap "Cnblogs")
    "cnblogs���Ϳͻ��˲˵�")

  (define-key menu-bar-cnblogs-menu [tags-getUsersBlogs]
    '(menu-item "�û���Ϣ" cnblogs-get-users-blogs
		:help "��ȡ�û��Ĳ�����Ϣ"))

  (define-key menu-bar-cnblogs-menu [tags-getRecentPosts]
    '(menu-item "��ȡ�������" cnblogs-get-recent-posts
		:help "��ȡ���������Nƪ����"))

  (define-key menu-bar-cnblogs-menu [tags-getCategories]
    '(menu-item "��ȡ�����£�����" cnblogs-get-categories
		:help "��ȡ�����±��ز��ͷ���"))

  (define-key menu-bar-cnblogs-menu [tags-getPost]
    '(menu-item "��ȡ����" cnblogs-get-post
		:help "��ȡ�����±���ָ���Ĳ���"))
  (define-key menu-bar-cnblogs-menu [separator-cnblogs-tags]
    '(menu-item "--"))

  (define-key menu-bar-cnblogs-menu [tags-editPost]
    '(menu-item "����" cnblogs-edit-post
		:help "�����ѷ����Ĳ���"))

  (define-key menu-bar-cnblogs-menu [tags-deletePost]
    '(menu-item "ɾ��" cnblogs-delete-post
		:help "����ǰ��������Ӧ�Ĳ���ɾ��"))

  (define-key menu-bar-cnblogs-menu [tags-saveDraft]
    '(menu-item "���" cnblogs-save-draft
		:help "���ݸ屣�浽����������״̬Ϊ��δ������"))

  (define-key menu-bar-cnblogs-menu [tags-newPost]
    '(menu-item "����" cnblogs-new-post
		:help "������ǰ������"))

  (define-key global-map [C-S-mouse-1]
    menu-bar-cnblogs-menu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;KeyMap;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (global-set-key (kbd "\C-c c p") 'cnblogs-new-post)
  (global-set-key (kbd "\C-c c s") 'cnblogs-save-draft)
  (global-set-key (kbd "\C-c c d") 'cnblogs-delete-post)
  (global-set-key (kbd "\C-c c e") 'cnblogs-edit-post)
  (global-set-key (kbd "\C-c c g") 'cnblogs-get-post)
  (global-set-key (kbd "\C-c c c") 'cnblogs-get-categories)
  (global-set-key (kbd "\C-c c r") 'cnblogs-get-recent-posts)
  (global-set-key (kbd "\C-c c u") 'cnblogs-get-users-blogs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;LoadData;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  )
(cnblogs-init)


(defun cnblogs-save-entry-list () 
  (with-temp-file "cnblogs-entry-list-file"
    (print cnblogs-entry-list
	   (current-buffer))))

(defun cnblogs-load-entry-list ()
  (find-file "cnblogs-entry-list-file")
  (let ((entry-buf
	 (get-buffer "cnblogs-entry-list-file")))
    (setq cnblogs-entry-list 
	  (condition-case ()
	      (read entry-buf)
	    (error nil)))
    (kill-buffer entry-buf)))

(cnblogs-load-entry-list) ;; todo: ���ڳ�ʼ���У����ͽ����庯������ǰ��


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
      (message "���óɹ�")
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
	(setq categories-string���������� ;Բ�ǰ�ǿո�
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
	;; name
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

  (let ((post-id  
	 (cnblogs-metaweblog-new-post (cnblogs-current-buffer-to-post)
				      t)))
    (setq cnblogs-entry-list
	  (cons (cnblogs-metaweblog-get-post post-id)
		cnblogs-entry-list))
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


(defun cnblogs-get-categories ()
  (interactive)
  (setq cnblogs-category-list
	(or 
	 (condition-case ()
	     (cnblogs-metaweblog-get-categories)
	   (error nil))
	 cnblogs-category-list))
  (cnblogs-save-category-list)
  (message "��ȡ����ɹ���"))



(defun cnblogs-save-category-list () 
  (with-temp-file "cnblogs-category-list-file"
    (print cnblogs-category-list
	   (current-buffer))))

(defun cnblogs-load-category-list ()
  (find-file "cnblogs-category-list-file")
  (let ((entry-buf
	 (get-buffer "cnblogs-category-list-file")))
    (setq cnblogs-entry-list 
	  (condition-case ()
	      (read entry-buf)
	    (error nil)))
    (kill-buffer entry-buf)))

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
