;;; agent-shell-manager-test.el --- Tests for agent-shell-manager -*- lexical-binding: t; -*-

;; Run from the repository root, with agent-shell, shell-maker and acp on
;; the load path:
;;
;;   emacs --batch -L . -L <agent-shell> -L <shell-maker> -L <acp> \
;;     -l test/agent-shell-manager-test.el -f ert-run-tests-batch-and-exit

(require 'ert)
(require 'cl-lib)
(require 'agent-shell-manager)

;;; Status mapping (pure)

(ert-deftest agent-shell-manager-status-killed-when-shell-process-dead ()
  (should (equal (agent-shell-manager--status-from
                  :shell-alive nil :agent-dead nil :initialized t
                  :status 'ready :session t)
                 "killed")))

(ert-deftest agent-shell-manager-status-killed-when-agent-process-dead ()
  (should (equal (agent-shell-manager--status-from
                  :shell-alive t :agent-dead t :initialized t
                  :status 'ready :session t)
                 "killed")))

(ert-deftest agent-shell-manager-status-initializing-before-init-finished ()
  (should (equal (agent-shell-manager--status-from
                  :shell-alive t :agent-dead nil :initialized nil
                  :status 'ready :session nil)
                 "initializing")))

(ert-deftest agent-shell-manager-status-maps-public-status ()
  (dolist (case '((blocked t "waiting")
                  (busy t "working")
                  (ready t "ready")
                  (ready nil "unknown")))
    (should (equal (agent-shell-manager--status-from
                    :shell-alive t :agent-dead nil :initialized t
                    :status (nth 0 case) :session (nth 1 case))
                   (nth 2 case)))))

;;; Model and mode names through the public config-option API

(defconst agent-shell-manager-test--model-option
  '((:id . "model") (:category . "model") (:current-value . "fable")
    (:options ((:value . "opus") (:name . "Opus 5.5"))
              ((:value . "fable") (:name . "Fable 5.2")))))

(ert-deftest agent-shell-manager-option-name-reads-current-choice ()
  (cl-letf (((symbol-function 'agent-shell-initialized-p) (lambda (&rest _) t))
            ((symbol-function 'agent-shell-config-option)
             (lambda (&rest _) agent-shell-manager-test--model-option)))
    (should (equal (agent-shell-manager--option-name (current-buffer) "model")
                   "Fable 5.2"))))

(ert-deftest agent-shell-manager-option-name-falls-back-to-value ()
  "A current value missing from the options list is shown as-is."
  (cl-letf (((symbol-function 'agent-shell-initialized-p) (lambda (&rest _) t))
            ((symbol-function 'agent-shell-config-option)
             (lambda (&rest _)
               '((:current-value . "custom-model") (:options)))))
    (should (equal (agent-shell-manager--option-name (current-buffer) "model")
                   "custom-model"))))

(ert-deftest agent-shell-manager-option-name-nil-when-unavailable ()
  "Not initialized, no such option, or an API error all give nil."
  (cl-letf (((symbol-function 'agent-shell-initialized-p) (lambda (&rest _) nil))
            ((symbol-function 'agent-shell-config-option)
             (lambda (&rest _) (error "Should not be called"))))
    (should-not (agent-shell-manager--option-name (current-buffer) "model")))
  (cl-letf (((symbol-function 'agent-shell-initialized-p) (lambda (&rest _) t))
            ((symbol-function 'agent-shell-config-option) (lambda (&rest _) nil)))
    (should-not (agent-shell-manager--option-name (current-buffer) "model")))
  (cl-letf (((symbol-function 'agent-shell-initialized-p) (lambda (&rest _) t))
            ((symbol-function 'agent-shell-config-option)
             (lambda (&rest _) (error "Several options share category"))))
    (should-not (agent-shell-manager--option-name (current-buffer) "model"))))

;;; agent-shell-manager-test.el ends here
