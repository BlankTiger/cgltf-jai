SOURCE_PATH   :: "source";
LIB_BASE_NAME :: "cgltf";

#run,stallable {
    set_build_options_dc(.{do_output=false});
    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
    }
}

generate_bindings :: () -> bool {
    source_file := tprint("%/cgltf.c", SOURCE_PATH);

    success := true;
    extra: [..] string;
    array_add(*extra, "-fPIC");

    success &&= build_cpp_static_lib(LIB_BASE_NAME, source_file, target = .LINUX, debug = false, extra = extra);

    if !success  return false;

    options: Generate_Bindings_Options;
    {
        using options;

        os = .LINUX;
        cpu = .X64;

        array_add(*libraries, .{filename=LIB_BASE_NAME});
        array_add(*source_files, tprint("%/cgltf.h", SOURCE_PATH));
        array_add(*typedef_prefixes_to_unwrap, "cgltf_");

        generate_library_declarations = false;
        try_to_preserve_comments = true;
        omit_global_declarations = false;
        auto_detect_enum_prefixes = true;
        log_stripped_declarations = true;
        generate_compile_time_struct_checks = false;

        footer = "cgltf :: #library,no_dll \"cgltf\";";
    }

    output_filename := "module.jai";
    return generate_bindings(options, output_filename);
}


#import "Basic";
#import "Bindings_Generator";
#import "BuildCpp";
#import "Compiler";
#import "File";
#import "Process";
