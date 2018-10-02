;;; packages.el --- circadian layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Travis Nesland <tnesland@lappy>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `circadian-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `circadian/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `circadian/pre-init-PACKAGE' and/or
;;   `circadian/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst circadian-packages
  '(circadian))

(defun circadian/init-circadian ()
  (use-package circadian
    :ensure t
    :config
    (setq circadian-themes '(("8:00" . doom-solarized-light)
                             ("19:00" . solarized-dark)))
    (circadian-setup))
  )

;;; packages.el ends here
