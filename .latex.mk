set_title = \
        case $$TERM in \
                screen*) \
                        printf '\033k'"$1"'\033\\';; \
        esac
