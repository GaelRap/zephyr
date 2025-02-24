/* SPDX-License-Identifier: Apache-2.0 */

	SECTION_PROLOGUE(initlevel,,)
	{
		/*
		 * link in initialization objects for all objects that are
		 * automatically initialized by the kernel; the objects are
		 * sorted in the order they will be initialized (i.e. ordered
		 * by level, sorted by priority within a level)
		 */
		__init_start = .;
		CREATE_OBJ_LEVEL(init, PRE_KERNEL_1)
		CREATE_OBJ_LEVEL(init, PRE_KERNEL_2)
		CREATE_OBJ_LEVEL(init, POST_KERNEL)
		CREATE_OBJ_LEVEL(init, APPLICATION)
		CREATE_OBJ_LEVEL(init, SMP)
		__init_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_PROLOGUE(devices,,)
	{
		/* Link in devices objects, which are tied to the init ones;
		 * the objects are thus sorted the same way as their init
		 * object parent. See above and include/device.h.
		 */
		__device_start = .;
		CREATE_OBJ_LEVEL(device, PRE_KERNEL_1)
		CREATE_OBJ_LEVEL(device, PRE_KERNEL_2)
		CREATE_OBJ_LEVEL(device, POST_KERNEL)
		CREATE_OBJ_LEVEL(device, APPLICATION)
		CREATE_OBJ_LEVEL(device, SMP)
		__device_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

#if defined(CONFIG_GEN_SW_ISR_TABLE) && !defined(CONFIG_DYNAMIC_INTERRUPTS)
	SECTION_PROLOGUE(sw_isr_table,,)
	{
		/*
		 * Some arch requires an entry to be aligned to arch
		 * specific boundary for using double word load
		 * instruction.  See include/sw_isr_table.h.
		 */
		. = ALIGN(CONFIG_ARCH_SW_ISR_TABLE_ALIGN);
		*(_SW_ISR_TABLE_SECTION_SYMS)
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)
#endif

	/* verify we don't have rogue .z_init_<something> initlevel sections */
	SECTION_PROLOGUE(initlevel_error,,)
	{
		KEEP(*(SORT(.z_init_[_A-Z0-9]*)))
	}
	ASSERT(SIZEOF(initlevel_error) == 0, "Undefined initialization levels used.")

#ifdef CONFIG_CPP_STATIC_INIT_GNU
	SECTION_PROLOGUE(_CTOR_SECTION_NAME,,)
	{
		/*
		 * The compiler fills the constructor pointers table below,
		 * hence symbol __CTOR_LIST__ must be aligned on word
		 * boundary.  To align with the C++ standard, the first element
		 * of the array contains the number of actual constructors. The
		 * last element is NULL.
		 */
#ifdef CONFIG_64BIT
		. = ALIGN(8);
		__CTOR_LIST__ = .;
		QUAD((__CTOR_END__ - __CTOR_LIST__) / 8 - 2)
		KEEP(*(SORT_BY_NAME(".ctors*")))
		QUAD(0)
		__CTOR_END__ = .;
#else
		. = ALIGN(4);
		__CTOR_LIST__ = .;
		LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
		KEEP(*(SORT_BY_NAME(".ctors*")))
		LONG(0)
		__CTOR_END__ = .;
#endif
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_PROLOGUE(init_array,,)
	{
		. = ALIGN(4);
		__init_array_start = .;
		KEEP(*(SORT_BY_NAME(".init_array*")))
		__init_array_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)
#endif
#ifdef CONFIG_USERSPACE
	/* Build-time assignment of permissions to kernel objects to
	 * threads declared with K_THREAD_DEFINE()
	 */
	ITERABLE_SECTION_ROM(z_object_assignment, 4)
#endif

	SECTION_DATA_PROLOGUE(app_shmem_regions,,)
	{
		__app_shmem_regions_start = .;
		KEEP(*(SORT(.app_regions.*)));
		__app_shmem_regions_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

#if defined(CONFIG_NET_SOCKETS)
	ITERABLE_SECTION_ROM(net_socket_register, 4)
#endif

#if defined(CONFIG_NET_L2_PPP)
	ITERABLE_SECTION_ROM(ppp_protocol_handler, 4)
#endif

	ITERABLE_SECTION_ROM(bt_l2cap_fixed_chan, 4)

#if defined(CONFIG_BT_BREDR)
	ITERABLE_SECTION_ROM(bt_l2cap_br_fixed_chan, 4)
#endif

#if defined(CONFIG_BT_CONN)
	ITERABLE_SECTION_ROM(bt_conn_cb, 4)
#endif

	ITERABLE_SECTION_ROM(bt_gatt_service_static, 4)

#if defined(CONFIG_BT_MESH)
	ITERABLE_SECTION_ROM(bt_mesh_subnet_cb, 4)
	ITERABLE_SECTION_ROM(bt_mesh_app_key_cb, 4)

	ITERABLE_SECTION_ROM(bt_mesh_hb_cb, 4)
#endif

#if defined(CONFIG_BT_MESH_FRIEND)
	ITERABLE_SECTION_ROM(bt_mesh_friend_cb, 4)
#endif

#if defined(CONFIG_BT_MESH_LOW_POWER)
	ITERABLE_SECTION_ROM(bt_mesh_lpn_cb, 4)
#endif

#if defined(CONFIG_BT_MESH_GATT_PROXY)
	ITERABLE_SECTION_ROM(bt_mesh_proxy_cb, 4)
#endif

#if defined(CONFIG_EC_HOST_CMD)
	ITERABLE_SECTION_ROM(ec_host_cmd_handler, 4)
#endif

#if defined(CONFIG_SETTINGS)
	ITERABLE_SECTION_ROM(settings_handler_static, 4)
#endif

	ITERABLE_SECTION_ROM(k_p4wq_initparam, 4)

#if defined(CONFIG_EMUL)
	SECTION_DATA_PROLOGUE(emulators_section,,)
	{
		__emul_list_start = .;
		KEEP(*(SORT_BY_NAME(".emulators")));
		__emul_list_end = .;
	} GROUP_LINK_IN(ROMABLE_REGION)
#endif /* CONFIG_EMUL */

#if defined(CONFIG_DNS_SD)
	ITERABLE_SECTION_ROM(dns_sd_rec, 4)
#endif

#if defined(CONFIG_PCIE)
	SECTION_DATA_PROLOGUE(irq_alloc,,)
	{
		__irq_alloc_start = .;
		KEEP(*(SORT_BY_NAME("._irq_alloc*")));
		__irq_alloc_end = .;
	} GROUP_LINK_IN(ROMABLE_REGION)
#endif /* CONFIG_PCIE */

	SECTION_DATA_PROLOGUE(log_strings_sections,,)
	{
		__log_strings_start = .;
		KEEP(*(SORT(.log_strings*)));
		__log_strings_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_DATA_PROLOGUE(log_const_sections,,)
	{
		__log_const_start = .;
		KEEP(*(SORT(.log_const_*)));
		__log_const_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_DATA_PROLOGUE(log_backends_sections,,)
	{
		__log_backends_start = .;
		KEEP(*("._log_backend.*"));
		__log_backends_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	ITERABLE_SECTION_ROM(shell, 4)

	SECTION_DATA_PROLOGUE(shell_root_cmds_sections,,)
	{
		__shell_root_cmds_start = .;
		KEEP(*(SORT(.shell_root_cmd_*)));
		__shell_root_cmds_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_DATA_PROLOGUE(font_entry_sections,,)
	{
		__font_entry_start = .;
		KEEP(*(SORT_BY_NAME("._cfb_font.*")))
		__font_entry_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	ITERABLE_SECTION_ROM(tracing_backend, 4)

	SECTION_DATA_PROLOGUE(zephyr_dbg_info,,)
	{
		KEEP(*(".dbg_thread_info"));
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)

	SECTION_DATA_PROLOGUE(device_handles,,)
	{
		__device_handles_start = .;
#ifdef LINKER_DEVICE_HANDLES_PASS1
		KEEP(*(SORT(.__device_handles_pass1*)));
#else
		KEEP(*(SORT(.__device_handles_pass2*)));
#endif /* LINKER_DEVICE_HANDLES_PASS1 */
		__device_handles_end = .;
	} GROUP_ROM_LINK_IN(RAMABLE_REGION, ROMABLE_REGION)
