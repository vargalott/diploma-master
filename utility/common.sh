#!/bin/bash

# =================================================================
#
#   MODULE: utility:common
#   LOCAL ENTRY POINT: *multiple*
#
#   utility
#   |-- common.sh *CURRENT*
#   |-- utility.sh
#
#   COMMENT: common DIALOG functions etc
#
# =================================================================

source $PROJ_ROOT_DIR/utility/utility.sh

dialog_input_path() {
  while true; do
    path=$($DIALOG --title "Choose file" --fselect $PROJ_ROOT_DIR 15 80 3>&1 1>&2 2>&3)

    case $? in
    $DIALOG_OK)
      if !([[ -f "$path" ]] || [[ -d "$path" ]]); then
        $DIALOG --title "Error" --msgbox "Wrong path!" 10 40
        continue
      fi
      retval=$path
      return
      ;;

    $DIALOG_CANCEL)
      return $DIALOG_CANCEL
      ;;

    $DIALOG_ESC)
      CLEAR_EXIT
      ;;

    esac
  done
}

dialog_input_password() {
  eval local title="$1"
  eval local text="$2"

  pass=$($DIALOG --clear --title "$title" --insecure --passwordbox "$text" 10 30 3>&1 1>&2 2>&3)

  case $? in
  $DIALOG_OK)
    retval=$pass
    ;;

  $DIALOG_CANCEL)
    return $DIALOG_CANCEL
    ;;

  $DIALOG_ESC)
    CLEAR_EXIT
    ;;

  esac
}

dialog_input_num() {
  eval local title="$1"
  eval local text="$2"

  while true; do
    num=$($DIALOG --clear --title "$title" --inputbox "$text" 10 30 3>&1 1>&2 2>&3)

    case $? in
    $DIALOG_OK)
      if [[ $num =~ ^[0-9]+$ ]]; then
        retval=$num
        return
      else
        $DIALOG --title "Error" --msgbox "Wrong number" 10 40
      fi

      ;;
    $DIALOG_CANCEL)
      return $DIALOG_CANCEL
      ;;

    $DIALOG_ESC)
      CLEAR_EXIT
      ;;

    esac
  done
}

dialog_get_sup() {
  #region ROOT IS REQUIRED

  export DIALOGRC=$PROJ_ROOT_DIR/utility/.warn.dialogrc

  SUDO_CRED_LOCK_RESET

  local title="ROOT ACCESS IS REQUIRED"
  local text="\nEnter your ROOT password"
  source $PROJ_ROOT_DIR/utility/common.sh dialog_input_password "\${title}" "\${text}"
  if [[ $? -eq $DIALOG_CANCEL ]]; then
    export DIALOGRC=$PROJ_ROOT_DIR/utility/.default.dialogrc
    return $RC_ERROR
  fi
  local rpass=$retval

  export HISTIGNORE='*sudo -S*'

  # validate root password(just random command)
  prompt=$(
    sudo -S uname -a 2>&1 <<<"$rpass"
    sudo -S -nv 2>&1
  )
  if [[ $? -ne 0 ]]; then
    $DIALOG --clear --title "Error" --msgbox "Wrong password" 10 40
    export DIALOGRC=$PROJ_ROOT_DIR/utility/.default.dialogrc
    return $RC_ERROR
  fi

  retval=$rpass

  SUDO_CRED_LOCK_RESET

  export DIALOGRC=$PROJ_ROOT_DIR/utility/.default.dialogrc

  #endregion
}

RESOLVE_FUNC_CALL $@
