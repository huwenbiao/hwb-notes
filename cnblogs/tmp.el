(define-derived-mode cnblogs-mode special-mode "Cnblogs-Manager"
  "管理博客园博客") 

(add-hook 'cnblogs-mode-hook 'cnblogs-init)
;(cnblogs-mode-hook)

;在博文中mt_keywords是tag标签
;在博客软件中加入分享到twitter的功能，将新建博文分享到twitter上。



(defun cnblogs()
  "用来启动Cnblogs-Manager"
  (interactive)


  (cnblogs-load-variables)
  (delete-other-windows)
  (setq cnbblogs-post-list-window 
	(split-window nil 55 "left"))

  
  (set-window-buffer cnblogs-post-list-window
		     (get-buffer-create "*Cnblogs*"))


					;生成内容
  (with-current-buffer "*Cnblogs*"
    (insert (cnblogs-make-content))
    (cnblogs-mode))


					;返回原来的窗口
					;todo: 这个命令未必在任何情况下都能返回原来的窗口，以后修改下
  (next-multiframe-window)
  )  

(defun cnblogs-format-content ()
  "格式化显示博文项及博文状态等信息"
  
  (setq cnbblogs-post-list-window 
	(split-window nil 30 "left"))

  
  (set-window-buffer cnblogs-post-list-window
		     (get-buffer-create "Cnblogs"))


  (with-current-buffer "Cnblogs"
    (insert "this is a test"))
  

					;返回原来的窗口
					;todo: 这个命令未必在任何情况下都能返回原来的窗口，以后修改下
  (next-multiframe-window)
  
  )




(defun cnblogs-make-content ()
  (let ((result ""))
    (mapc (lambda (category)           ;分类及其中的博文
	    (let ((posts-in-cat "")    ;属于该分类的博文
		  (posts-cnt 0))       ;属于该分类的博文数目
	      (mapc (lambda (entry)
		      (progn
			(setq posts-cnt 
			      (1+ posts-cnt))
			(setq posts-in-cat
			      (concat ""
				      (with-temp-buffer
					(insert-image '(image :type xpm :file "~/cnblogs-guide.xpm"))
					(insert-image '(image :type xpm :file "~/cnblogs-handle.xpm"))
					(insert-image '(image :type xpm :file "~/cnblogs-leaf.xpm"))
					(buffer-string))
				      (propertize (nth 1 entry)
						  'face 'italic
						  'mouse-face 'bold-italic
						  'comment t
						  'face 'highlight
						  )
				      "\n"
				      posts-in-cat))))

		      (cdr category))
	      (setq result (concat
			    (with-temp-buffer
			      (insert-image '(image :type xpm :file "~/cnblogs-open.xpm") )
			      (buffer-string))
			    " "
			    (car category)
			    " ["
			    (int-to-string posts-cnt)
			    "]\n"
			    posts-in-cat
			    result))))
	  cnblogs-posts-in-category)
    result)
  )
