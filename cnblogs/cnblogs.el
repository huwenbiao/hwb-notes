;;; entry type
;;
;; (id title postid categories src-file state)

(defgroup cnblogs nil
  "博客园客户端分组"
  :group 'emacs)

(defun cnblogs-define-variables () ;; todo: 变量以后要改成nil
  "定义及初始化各变量"
  (defcustom cnblogs-server-url nil
    "MetaWeblog访问地址"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-blog-id nil
    "博客ID"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-user-name nil
    "登录用户名"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-user-passwd nil
    "用户密码"
    :group 'cnblogs
    :type 'string)
  (defcustom cnblogs-media-object-suffix-list '("jpg" "jpeg" "png" "gif" "mp4")
    "希望处理的媒体文件类型"
    :group 'cnblogs
    :type 'list)
  (defcustom cnblogs-template-head
    "#TITLE:    \n#KEYWORDS: \n#DATE:    \n"
    "博客头模板"
    :group 'cnblogs)
  :type 'list
  (defcustom cnblogs-file-root-path "~/.Cnblogs/"
    "数据文件的根目录"
    :group 'cnblogs
    :type 'string)

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (defvar cnblogs-posts-in-category nil
    "分类之后的博文，这是显示在Cnblogs-Manager缓冲区里的主要内容")
  (defvar cnblogs-entry-list-file
    (concat cnblogs-file-root-path "entry-list-file")
    "博文项列表文件")
  (defvar cnblogs-file-post-path
    (concat cnblogs-file-root-path "post/")
    "博文内容文件根目录，其中的博文内容文件以博文ｉｄ命名")
  (defvar cnblogs-category-list nil
    "博文分类列表")
  (defvar cnblogs-category-list-file 
    (concat cnblogs-file-root-path "category-list-file")
    "博文分类列表")
  (defvar cnblogs-blog-info nil
    "博客信息")
  (defvar cnblogs-entry-list nil
    "本地博客列表")
  (defvar cnblogs-category-list nil
    "分类列表")
  (defvar cnblogs-post-list-window nil
    "博文列表窗口")
  (setq  test-post  `(("title" . "博文题目") 
		      ("dateCreated" :datetime (20423 52590))
		      ("categories"  "categories" "[随笔分类]Emacs" "[随笔分类]Linux应用")
		      ("description" . "博文正文。")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;Menu;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (defvar cnblogs-mode-map
    (make-sparse-keymap "Cnblogs")
    "cnblogs博客客户端菜单")

  (define-key cnblogs-mode-map [tags-getUsersBlogs]
    '(menu-item "用户信息" cnblogs-get-users-blogs
		:help "获取用户的博客信息"))

  (define-key cnblogs-mode-map [tags-getRecentPosts]
    '(menu-item "获取最近发布" cnblogs-get-recent-posts
		:help "获取最近发布的N篇博客"))

  (define-key cnblogs-mode-map [tags-getCategories]
    '(menu-item "获取（更新）分类" cnblogs-get-categories
		:help "获取并更新本地博客分类"))

  (define-key cnblogs-mode-map [tags-getPost]
    '(menu-item "获取博客" cnblogs-get-post
		:help "获取并更新本地指定的博客"))
  (define-key cnblogs-mode-map [separator-cnblogs-tags]
    '(menu-item "--"))

  (define-key cnblogs-mode-map [tags-editPost]
    '(menu-item "更新" cnblogs-edit-post
		:help "更新已发布的博客"))

  (define-key cnblogs-mode-map [tags-deletePost]
    '(menu-item "删除" cnblogs-delete-post
		:help "将当前缓冲区对应的博客删除"))

  (define-key cnblogs-mode-map [tags-saveDraft]
    '(menu-item "存稿" cnblogs-save-draft
		:help "将草稿保存到服务器，但状态为“未发布”"))

  (define-key cnblogs-mode-map [tags-newPost]
    '(menu-item "发布" cnblogs-new-post
		:help "发布当前缓冲区"))

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
  "加载各变量的值";
					;加载博文项列表
  (cnblogs-load-entry-list)
					;加载博文分类
  (cnblogs-load-category-list)
					;将博文项列表中的项加入到相应的分类中去
  (mapc (lambda (categorie)
	  (progn
					;先将该分类加入
	    (push (cons categorie nil)
		  cnblogs-posts-in-category)
	    )
	  
					;将属于该分类的项加入该分类
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

;(cnblogs-load-entry-list) ;; todo: 放在初始化中，但就将定义函数放在前面
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
					;先将分类格式简化，只留取名字
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
	(read-string "输入你的博客ID：" nil nil))
  (setq cnblogs-user-name
	(read-string "输入你的用户名：" nil nil))
  (setq cnblogs-user-passwd
	(read-passwd "输入你的密码：" nil ))
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
	;; 如果没有.Cnblogs目录，则新建这个目录
	(or (file-directory-p "~/.Cnblogs")
	    (make-directory "~/.Cnblogs"))
	(cnblogs-save-category-list)
	(message "设置成功"))
    (message "设置失败")))

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
  "将分类字符串按空白符分成字符串列表"
  (if (or (eq categories-string nil)
	  (eq categories-string ""))
      nil
    (let ((idx1
	   (string-match "[^　 \t]+"    ;圆角半角空格
			 categories-string)))
      (if (not idx1)
	  nil
	(setq categories-string         ;圆角半角空格
	      (substring categories-string idx1))
	(let ((idx2 
	       (string-match "[　 \t]+"
			     categories-string)))
	  (if idx2
	      (cons (concat "[随笔分类]"
			    (substring categories-string 
				       0
				       idx2))
		    (cnblogs-categories-string-to-list (substring categories-string
								  idx2)))
	    (cons (concat "[随笔分类]"
			  categories-string)
		  nil)))))))

(defun cnblogs-insert-template-head ()
  "插入头模板"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (insert cnblogs-template-head)))

(defun cnblogs-make-media-object-file-data (media-path) ;todo: type以后加上
  "根据给出的文件路径返回相应的FileData，文件不存在返回nil"
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
  "处理BUF-STR中的媒体文件，返回处理后的字符串"
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
		      "新随笔"))

	    ;; categories
	    (cons "categories"
		  (let ((categories-list
			 (cnblogs-categories-string-to-list
			  (cnblogs-fetch-field "KEYWORDS"))))
		    (or
		     categories-list
		     '("[随笔分类]未分类"))))

	    ;; dateCreated
	    (cons "dateCreated"
		  (list 
		   :datetime
		   (condition-case ()
		       (date-to-time (cnblogs-fetch-field "DATE")) ;todo: 要转化
		     (error (progn
			      (message "时间格式不支持，使用默认时间:1989-05-17 00:00")
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

(defun cnblogs-other-mode-buffer-to-post () ;todo: post还不完全
  (delq nil
	(list
	 ;; title
	 (cons "title"
	       (or (cnblogs-fetch-field "TITLE")
		   "新随笔"))
	 
	 
	 ;; categories
	 (cons "categories"
	       (let ((categories-list
		      (cnblogs-categories-string-to-list
		       (cnblogs-fetch-field "KEYWORDS"))))
		 (or
		  categories-list
		  '("[随笔分类]未分类"))))

	 
	 ;; dateCreated
	 (cons "dateCreated"
	       (list 
		:datetime
		(condition-case ()
		    (date-to-time (cnblogs-fetch-field "DATE")) ;todo: 要转化
		  (error (progn
			   (message "时间格式不支持，使用默认时间:1989-05-17 00:00")
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
  
  (let ((post-id  ;得到博文ｉｄ
	 (cnblogs-metaweblog-new-post (cnblogs-current-buffer-to-post)
				      t))
					;得到博文内容
	(post-content
	 (cnblogs-metaweblog-get-post post-id)))
					;生成新的博文项列表
					;todo:这里要刷新列表
    (setq cnblogs-entry-list
	  (cons (cnblogs-make-entry post-content)
		cnblogs-entry-list))
					;保存博文内容，文件名为博文ｉｄ
    (with-temp-file (concat cnblogs-file-post-path post-id)
      (print post-content
	     (current-buffer)))
					;保存博文项列表
    (cnblogs-save-entry-list))
  (message "发布随笔成功！"))



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
  (message "保存草稿成功！"))

(defun cnblogs-delete-post-from-entry-list (blog-id) 
  "POST-ID是string类型"
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

(defun cnblogs-delete-post ();todo:本地保存
  (interactive)
  (let ((blog-id
	 (cnblogs-get-blog-id-by-title
	  (cnblogs-fetch-field "title"))))
    (if (and blog-id
	     (yes-or-no-p "如果删除，本地信息也会删除。确定要删除吗？")
	     (cnblogs-metaweblog-delete-post blog-id t)
	     (cnblogs-delete-post-from-entry-list blog-id))
	(message "删除成功！")
      (message "删除失败！"))))


(defun cnblogs-edit-post ();;todo:更新本地
  (interactive)
  (let ((blog-id
	 (cnblogs-get-blog-id-by-title
	  (cnblogs-fetch-field "title"))))
    (if (and blog-id
	     (yes-or-no-p "确定要更新吗？")
	     (cnblogs-metaweblog-edit-post blog-id
					   (cnblogs-current-buffer-to-post)
					   t))
	(message "更新成功！")
      (message "更新失败！"))))

(defun cnblogs-get-post ()
  (interactive)
  (let* ((post-id
	  (read-string "输入要获取的随笔ID："))
	 (post
	  (condition-case ()
	      (cnblogs-metaweblog-get-post post-id)
	    (error nil))))
    (if (and post-id
	     (cnblogs-delete-post-from-entry-list post-id)
	     post
	     (setq cnblogs-entry-list
		   (cons post cnblogs-entry-list)))
	(message "获取成功！")
      (message "获取失败"))))

;; 获取并保存分类
(defun cnblogs-get-categories ()
  (interactive)
  (setq cnblogs-category-list
	(condition-case ()
	    (cnblogs-metaweblog-get-categories)
	  (error nil)))
  (if cnblogs-category-list
      (progn
	(cnblogs-save-category-list)
	(message "获取分类成功！"))
    (message "获取分类失败")))




(defun cnblogs-get-recent-posts ()
  (interactive)
  (let* ((num (read-number "输入要获取的随笔篇数："
			   1))
	 (posts (condition-case ()
		    (cnblogs-metaweblog-get-recent-posts num)
		  (error nil))))
    (if (not posts)
	(message "获取失败！")
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
	(message "获取成功！")))))

(defun cnblogs-get-users-blogs ()
  (interactive)
  (setq cnblogs-blog-info
	(condition-case ()
	    (prog1
		(cnblogs-metaweblog-get-users-blogs)
	      (message "获取用户博客信息成功！"))
	  (error cnblogs-blog-info))))





;; 下面是关于minor mode的内容
(defun cnblogs-init ()
  "Cnblogs的所有初始化工作"
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
