set(POST_COPY_DLL_CMD ${CMAKE_SOURCE_DIR}/cmake/deploy/post_copy_dlls.cmake)
set(COPY_IF_NOT_EXISTS_CMD ${CMAKE_SOURCE_DIR}/cmake/deploy/copy_if_not_exists.cmake)

function(deploy_exported_target_dependencies TARGET_NAME)
    if(WIN32)
        foreach(EXPORTED_TARGET ${ARGN})
            add_custom_command(
                TARGET ${TARGET_NAME} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${EXPORTED_TARGET}>
                        $<TARGET_FILE_DIR:${TARGET_NAME}>)
        endforeach()
    endif()
endfunction()

function(deploy_dependencies TARGET_NAME TARGET_DEPENDENCIES_COMMON TARGET_DEPENDENCIES_DEBUG
         TARGET_DEPENDENCIES_RELEASE)
    # ##################################################################################################################
    # common libs, copy always (if changed)
    # ##################################################################################################################
    foreach(f ${TARGET_DEPENDENCIES_COMMON})
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${f}"
                                                                    "${OUT_DIR}")
    endforeach()

    # ##################################################################################################################
    # debug specific libs (copy if the build/configuration type is matching)
    # ##################################################################################################################
    foreach(f ${TARGET_DEPENDENCIES_DEBUG})
        add_custom_command(
            TARGET ${TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -DBUILD_TYPE=$<CONFIG> -DOUT_DIR=${OUT_DIR}
                                                     -DFILE="${f}" -DCURRENT_DLL="Debug" -P ${POST_COPY_DLL_CMD})
    endforeach()

    # ##################################################################################################################
    # release specific libs (copy if the build/configuration type is matching)
    # ##################################################################################################################
    foreach(f ${TARGET_DEPENDENCIES_RELEASE})
        add_custom_command(
            TARGET ${TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -DBUILD_TYPE=$<CONFIG> -DOUT_DIR=${OUT_DIR}
                                                     -DFILE="${f}" -DCURRENT_DLL="Release" -P ${POST_COPY_DLL_CMD})
        add_custom_command(
            TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -DBUILD_TYPE=$<CONFIG> -DOUT_DIR=${OUT_DIR} -DFILE="${f}"
                    -DCURRENT_DLL="RelWithDebInfo" -P ${POST_COPY_DLL_CMD})
    endforeach()
endfunction()

function(add_install_stage_to_target TARGET_NAME)
    # the artifacts generated by the target to be installed. Only for release

    install(
        DIRECTORY ${OUT_DIR}/
        DESTINATION ${CMAKE_BINARY_DIR}/install
        CONFIGURATIONS RELEASE RELWITHDEBINFO
        PATTERN "*_UTest.*" EXCLUDE
        PATTERN "*-deployed.stamp" EXCLUDE
        PATTERN "*.pdb" EXCLUDE
        PATTERN "*.ipdb" EXCLUDE
        PATTERN "*.ilk" EXCLUDE
        PATTERN "*.iobj" EXCLUDE
        PATTERN "gmock*.dll" EXCLUDE
        PATTERN "gtest*.dll" EXCLUDE
        PATTERN "*d.dll" EXCLUDE
        PATTERN "vc_redist*" EXCLUDE)

    

    install(TARGETS ${TARGET_NAME} RUNTIME DESTINATION ${CMAKE_BINARY_DIR}/install CONFIGURATIONS RELEASE
                                                                                                  RELWITHDEBINFO)
endfunction()
 