{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;

    functions = {
      y = {
        body = ''
            set tmp (mktemp -t "yazi-cwd.XXXXXX")
            yazi $argv --cwd-file="$tmp"
            if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
        '';
      };
      link_report = {
        description = "Deluxe link info: hardlinks, symlinks, warnings";
        body = ''
          set -l dir ""
          for arg in $argv
              if not string match -qr '^--' -- $arg
                  set dir $arg
                  break
              end
          end
          if test -z "$dir"
              set dir "."
          end
          set dir (realpath $dir)

    set -l mode normal
    set -l only ""
    set -l output_file ""
    set -l show_size 0
    set -l types
    set -l exclude_patterns
    set -l case_sensitive 0

    # Parse options
    for arg in $argv
        switch $arg
            case '--help'
                echo "Usage: link_report_deluxe [DIRECTORY] [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --verbose                   Show inode numbers."
                echo "  --interactive               Prompt before deleting broken symlinks or orphans."
                echo "  --only=GROUP                 Only show a specific group: hardlinks, symlinks, or orphans."
                echo "  --markdown=FILE              Output results to a markdown file."
                echo "  --show-size                  Show file sizes with dust."
                echo "  --types=ext1,ext2,...        Only include files with these extensions."
                echo "  --exclude=regex1,regex2,...  Exclude files matching these regex patterns."
                echo "  --case-sensitive-types       Make --types matching case-sensitive."
                echo "  --help                       Show this help message."
                return 0
            case '--verbose'
                set mode verbose
            case '--interactive'
                set mode interactive
            case '--show-size'
                set show_size 1
            case '--case-sensitive-types'
                set case_sensitive 1
            case '--markdown=*'
                set output_file (string replace -- "--markdown=" "" $arg)
            case '--only=*'
                set only (string replace -- "--only=" "" $arg)
            case '--types=*'
                set types (string split "," (string replace -- "--types=" "" $arg))
            case '--exclude=*'
                set exclude_patterns (string split "," (string replace -- "--exclude=" "" $arg))
        end
    end

    function log
        if test -n "$output_file"
            echo -e $argv >> $output_file
        else
            echo -e $argv
        end
    end

    function prompt_delete --argument file --no-scope-shadowing
        while true
            echo -n (set_color red)"Delete $file? (y/N): "(set_color normal)
            read -l ans
            switch $ans
                case y Y
                    rm -v -- $file
                    return
                case \'\' n N
                    return
                case '*'
                    echo "Please answer y or n."
            end
        end
    end

    # File filtering helper
    function should_include_file --argument file --no-scope-shadowing
        set filename (basename $file)

        if test (count $exclude_patterns) -gt 0
            for pattern in $exclude_patterns
                set regex ".*\\.$pattern\$"
                if string match -q -r -- $regex -- $filename
                    return 1
                end
            end
        end

        if test (count $types) -gt 0
            set match 0
            for ext in $types
                set pattern ".*\\.$ext\$"
                if test $case_sensitive -eq 1
                    if string match -rq -- $pattern -- $filename
                        set match 1
                        break
                    end
                else
                    if string match -riq -- $pattern -- $filename
                        set match 1
                        break
                    end
                end
            end
            if test $match -eq 0
                return 1
            end
        end


        return 0
    end

    if test -n "$output_file"
        echo "# Link Report for $dir" > $output_file
        echo "" >> $output_file
    end

    log (set_color yellow)"🔍 Scanning:"(set_color normal) " $dir"
    log ""

    # --------- Hardlinks section ----------
    if test "$only" = "" -o "$only" = "hardlinks"
        log (set_color cyan)"📦 Hardlink groups:"(set_color normal)

        set -l inode_map
        set -l inode_files

        for file in (find $dir -type f -printf "%i %p\n" 2>/dev/null)
            set inode (echo $file | awk '{print $1}')
            set path (string sub --start (math (string length $inode) + 2) -- $file)

            if should_include_file $path
                set inode_map[$inode] (string join \n $inode_map[$inode] $path)
                set inode_files $inode_files $path
            end
        end

        set -q inode_map || set -l inode_map
        set keys (printf "%s\n" (string match -r '.*' -- $inode_map | string split \n | string match -r '^\d+' | sort -u))

        if test (count $keys) -eq 0
            log "(none)"
        else
            for inode in (string match -r '.*' -- $keys | sort)
                set group (string split \n $inode_map[$inode])

                if test (count $group) -gt 1
                    if test "$mode" = "verbose"
                        log "Inode $inode:"
                    end
                    for path in (printf "%s\n" $group | sort)
                        log "  $path"
                    end
                    log ""
                end
            end
        end
        log ""

        if test $show_size -eq 1 -a (count $inode_files) -gt 0
            log (set_color green)"Sizes of hardlinked files:"(set_color normal)
            printf "%s\0" $inode_files | xargs -0 -r dust -n 10
            log ""
        end
    end

    # --------- Symlinks section ----------
    if test "$only" = "" -o "$only" = "symlinks"
        log (set_color cyan)"🔗 Symlinks:"(set_color normal)
        set -l symlinks

        for link in (find $dir -type l 2>/dev/null)
            if should_include_file $link
                set symlinks $symlinks $link
            end
        end

        if test (count $symlinks) -eq 0
            log "(none)"
        else
            for link in (printf "%s\n" $symlinks | sort)
                set target (readlink -f -- $link 2>/dev/null)
                if test -e "$target"
                    log (set_color green)"$link"(set_color normal)" → "(set_color blue)"$target"(set_color normal)
                else
                    log (set_color red)"$link"(set_color normal)" → "(set_color red)"[BROKEN]"(set_color normal)
                    if test "$mode" = "interactive"
                        prompt_delete $link
                    end
                end
            end
        end

        log ""

        if test $show_size -eq 1 -a (count $symlinks) -gt 0
            log (set_color green)"Sizes of symlinks:"(set_color normal)
            printf "%s\0" $symlinks | xargs -0 -r dust -n 10
            log ""
        end
    end

    # --------- Orphans section ----------
    if test "$only" = "" -o "$only" = "orphans"
        log (set_color cyan)"👻 Orphan files (single link, no symlink):"(set_color normal)

        set -l symlink_targets
        for l in (find $dir -type l 2>/dev/null)
            set resolved (readlink -f -- $l 2>/dev/null)
            if test -n "$resolved"
                set symlink_targets $symlink_targets $resolved
            end
        end

        set -l orphans
        for file in (find $dir -type f -links 1 2>/dev/null)
            if should_include_file $file
                set real (realpath $file)
                if not contains -- $real $symlink_targets
                    set orphans $orphans $file
                end
            end
        end

        if test (count $orphans) -eq 0
            log "(none)"
        else
            for orphan in (printf "%s\n" $orphans | sort)
                log (set_color magenta)"$orphan"(set_color normal)
                if test "$mode" = "interactive"
                    prompt_delete $orphan
                end
            end
        end

        log ""

        if test $show_size -eq 1 -a (count $orphans) -gt 0
            log (set_color green)"Sizes of orphans:"(set_color normal)
            printf "%s\0" $orphans | xargs -0 -r dust -n 10
            log ""
        end
    end

    if test -n "$output_file"
        echo ""
        echo (set_color yellow)"✅ Markdown report saved to $output_file"(set_color normal)
    end
        '';
      };
    test_function = {
      body = ''
        log "This is a log."
      '';  
    };
    };
  };
}
