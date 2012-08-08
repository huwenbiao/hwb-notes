(define-derived-mode cnblogs-mode special-mode "Cnblogs-Manager"
  "管理博客园博客") 
  
  
(define-key cnblogs-mode-map [menu-bar menu-bar-cnblogs-menu]
  (cons "博客园" cnblogs-mode-map))

(add-hook 'cnblogs-mode-hook 'cnblogs-init)
;(cnblogs-mode-hook)
