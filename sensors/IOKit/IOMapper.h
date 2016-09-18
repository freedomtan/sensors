/*
 * Copyright (c) 1998-2003 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 * 
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */

#ifndef __IOKIT_IOMAPPER_H
#define __IOKIT_IOMAPPER_H

#include <sys/cdefs.h>

__BEGIN_DECLS
#include <IOKit/IOTypes.h>
#include <mach/vm_types.h>

// These are C accessors to the system mapper for non-IOKit clients
ppnum_t IOMapperIOVMAlloc(unsigned pages);
void IOMapperIOVMFree(ppnum_t addr, unsigned pages);

ppnum_t IOMapperInsertPage(ppnum_t addr, unsigned offset, ppnum_t page);
void IOMapperInsertPPNPages(ppnum_t addr, unsigned offset,
                            ppnum_t *pageList, unsigned pageCount);
void IOMapperInsertUPLPages(ppnum_t addr, unsigned offset,
                            upl_page_info_t *pageList, unsigned pageCount);

mach_vm_address_t IOMallocPhysical(mach_vm_size_t size, mach_vm_address_t mask);

void IOFreePhysical(mach_vm_address_t address, mach_vm_size_t size);

__END_DECLS

#if __cplusplus

#include <IOKit/IOService.h>
#include <IOKit/IOMemoryDescriptor.h>
#include <IOKit/IODMACommand.h>

class OSData;

extern const OSSymbol * gIOMapperIDKey;

class IOMapper : public IOService
{
    OSDeclareAbstractStructors(IOMapper);

    // Give the platform expert access to setMapperRequired();
    friend class IOPlatformExpert;

private:
    enum SystemMapperState {
        kNoMapper  = 0,
        kUnknown   = 1,
        kHasMapper = 2,	// Any other value is pointer to a live mapper
        kWaitMask  = 3,
    };
protected:
    void *fTable;
    ppnum_t fTablePhys;
    IOItemCount fTableSize;
    OSData *fTableHandle;
    bool fIsSystem;


    static void setMapperRequired(bool hasMapper);
    static void waitForSystemMapper();

    virtual bool initHardware(IOService *provider) = 0;

    virtual bool allocTable(IOByteCount size);

public:
    virtual bool start(IOService *provider);
    virtual void free();

    // Static routines capable of allocating tables that are physically
    // contiguous in real memory space.
    static OSData * NewARTTable(IOByteCount size,
                                void ** virtAddrP, ppnum_t *physAddrP);
    static void FreeARTTable(OSData *handle, IOByteCount size);


    // To get access to the system mapper IOMapper::gSystem 
    static IOMapper *gSystem;

    virtual ppnum_t iovmAlloc(IOItemCount pages) = 0;
    virtual void iovmFree(ppnum_t addr, IOItemCount pages) = 0;

    virtual void iovmInsert(ppnum_t addr, IOItemCount offset, ppnum_t page) = 0;
    virtual void iovmInsert(ppnum_t addr, IOItemCount offset,
                            ppnum_t *pageList, IOItemCount pageCount);
    virtual void iovmInsert(ppnum_t addr, IOItemCount offset,
                            upl_page_info_t *pageList, IOItemCount pageCount);

    static void checkForSystemMapper()
        { if ((uintptr_t) gSystem & kWaitMask) waitForSystemMapper(); };

    static IOMapper * copyMapperForDevice(IOService * device);

	
    // Function will panic if the given address is not found in a valid
    // iovm mapping.
    virtual addr64_t mapAddr(IOPhysicalAddress addr) = 0;

    // Get the address mask to or into an address to bypass this mapper
    virtual bool getBypassMask(addr64_t *maskP) const;

    virtual ppnum_t iovmAllocDMACommand(IODMACommand * command, IOItemCount pageCount);
    virtual void iovmFreeDMACommand(IODMACommand * command, ppnum_t addr, IOItemCount pageCount);
    
    virtual ppnum_t iovmMapMemory(
    			  OSObject                    * memory,   // dma command or iomd
			  ppnum_t                       offsetPage,
			  ppnum_t                       pageCount,
			  uint32_t                      options,
			  upl_page_info_t             * pageList,
			  const IODMAMapSpecification * mapSpecification);

    OSMetaClassDeclareReservedUsed(IOMapper, 0);
    OSMetaClassDeclareReservedUsed(IOMapper, 1);
    OSMetaClassDeclareReservedUsed(IOMapper, 2);
    OSMetaClassDeclareReservedUsed(IOMapper, 3);

private:
    OSMetaClassDeclareReservedUnused(IOMapper, 4);
    OSMetaClassDeclareReservedUnused(IOMapper, 5);
    OSMetaClassDeclareReservedUnused(IOMapper, 6);
    OSMetaClassDeclareReservedUnused(IOMapper, 7);
    OSMetaClassDeclareReservedUnused(IOMapper, 8);
    OSMetaClassDeclareReservedUnused(IOMapper, 9);
    OSMetaClassDeclareReservedUnused(IOMapper, 10);
    OSMetaClassDeclareReservedUnused(IOMapper, 11);
    OSMetaClassDeclareReservedUnused(IOMapper, 12);
    OSMetaClassDeclareReservedUnused(IOMapper, 13);
    OSMetaClassDeclareReservedUnused(IOMapper, 14);
    OSMetaClassDeclareReservedUnused(IOMapper, 15);
};

#endif /* __cplusplus */

#endif /* !__IOKIT_IOMAPPER_H */
